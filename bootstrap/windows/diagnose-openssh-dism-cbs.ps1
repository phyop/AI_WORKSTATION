#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Read-only OpenSSH Server capability diagnostics (DISM / CBS first).

.DESCRIPTION
  Does NOT run Add-WindowsCapability / Remove-WindowsCapability / firewall changes.
  Collects pending reboot signals, TrustedInstaller/WU service state, OpenSSH
  capability state, and filtered excerpts from CBS.log / DISM.log.

  Output:
    %ProgramData%\AIWorkstation\openssh-dism-cbs-diagnose.json
    %ProgramData%\AIWorkstation\openssh-dism-cbs-excerpts.txt

  NOTE: This script is ASCII/UTF-8-with-BOM so Windows PowerShell 5.1 parses it
  correctly on Traditional Chinese Windows code pages.
#>
[CmdletBinding()]
param(
  [int]$CbsTailLines = 8000,
  [int]$DismTailLines = 4000,
  [int]$MaxExcerptHits = 120
)

$ErrorActionPreference = 'Continue'
$reportDir = Join-Path $env:ProgramData 'AIWorkstation'
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

$jsonPath = Join-Path $reportDir 'openssh-dism-cbs-diagnose.json'
$excerptPath = Join-Path $reportDir 'openssh-dism-cbs-excerpts.txt'

$cbsLog = Join-Path $env:SystemRoot 'Logs\CBS\CBS.log'
$dismLog = Join-Path $env:SystemRoot 'Logs\DISM\dism.log'
$pendingXml = Join-Path $env:SystemRoot 'WinSxS\pending.xml'
$capabilityName = 'OpenSSH.Server~~~~0.0.1.0'

function Get-SafeService {
  param([string]$Name)
  try {
    $svc = Get-Service -Name $Name -ErrorAction Stop
    return [ordered]@{
      exists = $true
      name = $svc.Name
      status = $svc.Status.ToString()
      start_type = $svc.StartType.ToString()
    }
  } catch {
    return [ordered]@{
      exists = $false
      name = $Name
      error = $_.Exception.Message
    }
  }
}

function Test-PendingRebootSignals {
  $signals = [ordered]@{}
  $cbsReboot = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
  $wuReboot = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
  $pfro = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'

  $signals.component_based_servicing_reboot_pending = Test-Path -LiteralPath $cbsReboot
  $signals.windows_update_reboot_required = Test-Path -LiteralPath $wuReboot

  $pendingFileRename = $false
  try {
    $val = (Get-ItemProperty -LiteralPath $pfro -Name PendingFileRenameOperations -ErrorAction Stop).PendingFileRenameOperations
    $pendingFileRename = $null -ne $val -and @($val).Count -gt 0
  } catch {
    $pendingFileRename = $false
  }
  $signals.pending_file_rename_operations = $pendingFileRename
  $signals.winsxs_pending_xml_exists = Test-Path -LiteralPath $pendingXml
  $signals.any_pending = (
    $signals.component_based_servicing_reboot_pending -or
    $signals.windows_update_reboot_required -or
    $signals.pending_file_rename_operations -or
    $signals.winsxs_pending_xml_exists
  )
  return $signals
}

function Get-OpenSshCapabilityState {
  $items = @()
  try {
    $caps = Get-WindowsCapability -Online -ErrorAction Stop |
      Where-Object { $_.Name -like 'OpenSSH*' }
    foreach ($cap in $caps) {
      # Use PSCustomObject so -ExpandProperty / .state works on Windows PowerShell 5.1.
      $items += [pscustomobject]@{
        name = $cap.Name
        state = $cap.State.ToString()
      }
    }
  } catch {
    return [ordered]@{
      error = $_.Exception.Message
      items = @()
    }
  }
  $targetItem = @($items | Where-Object { $_.name -eq $capabilityName } | Select-Object -First 1)
  $targetState = $null
  if ($targetItem.Count -gt 0) {
    $targetState = [string]$targetItem[0].state
  }
  return [ordered]@{
    error = $null
    items = $items
    target = $capabilityName
    target_state = $targetState
  }
}

function Get-LogExcerpts {
  param(
    [string]$Path,
    [int]$TailLines,
    [string[]]$Patterns,
    [int]$MaxHits
  )

  $result = [ordered]@{
    path = $Path
    exists = Test-Path -LiteralPath $Path
    size_bytes = $null
    last_write_time = $null
    match_count = 0
    matches = @()
    read_error = $null
  }

  if (-not $result.exists) {
    return $result
  }

  try {
    $item = Get-Item -LiteralPath $Path -ErrorAction Stop
    $result.size_bytes = $item.Length
    $result.last_write_time = $item.LastWriteTime.ToString('o')

    # CBS.log can be large; only scan the tail.
    $lines = Get-Content -LiteralPath $Path -Tail $TailLines -ErrorAction Stop
    $joinedPattern = ($Patterns | ForEach-Object { [regex]::Escape($_) }) -join '|'
    $regex = "(?i)($joinedPattern)|HRESULT|0x800f|pending operation|OpenSSH|TrustedInstaller|FoD|Feature on Demand|failed|error"
    $hits = @(
      $lines |
        Select-String -Pattern $regex |
        Select-Object -Last $MaxHits
    )
    $result.match_count = $hits.Count
    $result.matches = @(
      $hits | ForEach-Object {
        [ordered]@{
          line_number = $_.LineNumber
          line = $_.Line.Trim()
        }
      }
    )
  } catch {
    $result.read_error = $_.Exception.Message
  }

  return $result
}

function Get-Hypothesis {
  param(
    $Pending,
    $Capability,
    $Sshd,
    $Cbs,
    $Dism
  )

  $notes = New-Object System.Collections.Generic.List[string]

  if ($Pending.any_pending) {
    $notes.Add('Pending reboot / pending.xml / PendingFileRenameOperations detected. Add-WindowsCapability may be blocked by CBS queue or stuck applying after reboot.')
  }

  if ($Capability.target_state -and $Capability.target_state -ne 'Installed') {
    $stateText = [string]$Capability.target_state
    $notes.Add(('OpenSSH.Server state is {0}; install is incomplete so sshd service may not exist yet.' -f $stateText))
  }

  if (-not $Sshd.exists) {
    $notes.Add('sshd service does not exist: capability install did not reach service registration, or it failed and rolled back.')
  }

  $textBlob = @(
    ($Cbs.matches | ForEach-Object { $_.line })
    ($Dism.matches | ForEach-Object { $_.line })
  ) -join "`n"

  if ($textBlob -match '(?i)pending operation|0x800f0806') {
    $notes.Add('Log shows pending operation / 0x800f0806: component servicing incomplete; repeating the same install is usually useless.')
  }
  if ($textBlob -match '(?i)0x800f0954|WSUS|Windows Server Update Services') {
    $notes.Add('Log points to WSUS / 0x800f0954: Features on Demand source may not provide the OpenSSH package.')
  }
  if ($textBlob -match '(?i)0x80072ee2|0x80072efd|WININET|download.*fail') {
    $notes.Add('Log points to network/download failure: FoD package was not retrieved from Windows Update.')
  }
  if ($textBlob -match '(?i)corrupt|0x80073712|0x800f0831|store corruption') {
    $notes.Add('Log points to component store corruption: consider SFC/DISM RestoreHealth later (not run by this script).')
  }
  if ($textBlob -match '(?i)OpenSSH\.Server' -and $textBlob -match '(?i)failed|error|HRESULT') {
    $notes.Add('CBS/DISM contain both OpenSSH.Server and failure text: use the nearest HRESULT/timestamp in the excerpts file.')
  }

  if ($notes.Count -eq 0) {
    $notes.Add('No single root cause from summary rules; inspect recent HRESULT / OpenSSH lines in openssh-dism-cbs-excerpts.txt.')
  }

  return @($notes)
}

Write-Host '=== OpenSSH DISM/CBS read-only diagnose (no install, no firewall changes) ===' -ForegroundColor Cyan

$pending = Test-PendingRebootSignals
$capability = Get-OpenSshCapabilityState
$sshd = Get-SafeService -Name 'sshd'
$sshAgent = Get-SafeService -Name 'ssh-agent'
$trustedInstaller = Get-SafeService -Name 'TrustedInstaller'
$wuauserv = Get-SafeService -Name 'wuauserv'

$cbs = Get-LogExcerpts -Path $cbsLog -TailLines $CbsTailLines -MaxHits $MaxExcerptHits -Patterns @(
  'OpenSSH',
  'OpenSSH.Server',
  'Capability',
  'FoD',
  'Features On Demand',
  'pending',
  'HRESULT_FROM_WIN32',
  'Error',
  'Failed'
)
$dism = Get-LogExcerpts -Path $dismLog -TailLines $DismTailLines -MaxHits $MaxExcerptHits -Patterns @(
  'OpenSSH',
  'OpenSSH.Server',
  'Add-WindowsCapability',
  'pending',
  'Error',
  'Failed',
  'HRESULT'
)

$firewall = [ordered]@{
  rule_name = 'OpenSSH-Server-In-TCP'
  exists = $false
  enabled = $false
}
try {
  $rule = Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction Stop
  $firewall.exists = $true
  $firewall.enabled = ($rule.Enabled -eq 'True')
} catch {
  $firewall.error = $_.Exception.Message
}

$hypotheses = Get-Hypothesis -Pending $pending -Capability $capability -Sshd $sshd -Cbs $cbs -Dism $dism

$report = [ordered]@{
  checked_at = (Get-Date).ToString('o')
  computer_name = $env:COMPUTERNAME
  os = (Get-CimInstance Win32_OperatingSystem | Select-Object -ExpandProperty Caption)
  build = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').CurrentBuild
  mode = 'read-only-diagnose'
  did_not_run = @(
    'Add-WindowsCapability',
    'Remove-WindowsCapability',
    'firewall changes',
    'service start/stop'
  )
  pending_reboot = $pending
  openssh_capability = $capability
  services = [ordered]@{
    sshd = $sshd
    ssh_agent = $sshAgent
    trusted_installer = $trustedInstaller
    wuauserv = $wuauserv
  }
  firewall = $firewall
  cbs_log = [ordered]@{
    path = $cbs.path
    exists = $cbs.exists
    size_bytes = $cbs.size_bytes
    last_write_time = $cbs.last_write_time
    match_count = $cbs.match_count
    read_error = $cbs.read_error
  }
  dism_log = [ordered]@{
    path = $dism.path
    exists = $dism.exists
    size_bytes = $dism.size_bytes
    last_write_time = $dism.last_write_time
    match_count = $dism.match_count
    read_error = $dism.read_error
  }
  hypotheses = $hypotheses
  next_actions = @(
    'Provide openssh-dism-cbs-diagnose.json and openssh-dism-cbs-excerpts.txt for follow-up analysis.',
    'Do NOT re-run install-openssh-server.ps1 until root cause is confirmed.',
    'If pending.any_pending=true: finish/clear CBS pending first; do not repeat Add-WindowsCapability.',
    'If excerpts show download/WU errors: verify Windows Update connectivity and FoD source settings.'
  )
}

$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $jsonPath -Encoding UTF8

$excerptBuilder = New-Object System.Text.StringBuilder
[void]$excerptBuilder.AppendLine("OpenSSH DISM/CBS excerpts  $($report.checked_at)")
[void]$excerptBuilder.AppendLine("Computer=$($report.computer_name) Build=$($report.build)")
[void]$excerptBuilder.AppendLine('')
[void]$excerptBuilder.AppendLine('=== Hypotheses ===')
foreach ($h in $hypotheses) {
  [void]$excerptBuilder.AppendLine("- $h")
}
[void]$excerptBuilder.AppendLine('')
[void]$excerptBuilder.AppendLine('=== CBS.log matches (tail-filtered) ===')
if (-not $cbs.exists) {
  [void]$excerptBuilder.AppendLine('(CBS.log not found)')
} elseif ($cbs.read_error) {
  [void]$excerptBuilder.AppendLine("READ ERROR: $($cbs.read_error)")
} elseif ($cbs.match_count -eq 0) {
  [void]$excerptBuilder.AppendLine('(no matches in tailed window)')
} else {
  foreach ($m in $cbs.matches) {
    [void]$excerptBuilder.AppendLine(('{0}: {1}' -f $m.line_number, $m.line))
  }
}
[void]$excerptBuilder.AppendLine('')
[void]$excerptBuilder.AppendLine('=== DISM.log matches (tail-filtered) ===')
if (-not $dism.exists) {
  [void]$excerptBuilder.AppendLine('(dism.log not found)')
} elseif ($dism.read_error) {
  [void]$excerptBuilder.AppendLine("READ ERROR: $($dism.read_error)")
} elseif ($dism.match_count -eq 0) {
  [void]$excerptBuilder.AppendLine('(no matches in tailed window)')
} else {
  foreach ($m in $dism.matches) {
    [void]$excerptBuilder.AppendLine(('{0}: {1}' -f $m.line_number, $m.line))
  }
}

Set-Content -LiteralPath $excerptPath -Value $excerptBuilder.ToString() -Encoding UTF8

Write-Host ''
Write-Host 'Capability:' -ForegroundColor Yellow
$capability | ConvertTo-Json -Depth 4 | Write-Host
Write-Host ''
Write-Host 'Pending reboot signals:' -ForegroundColor Yellow
$pending | ConvertTo-Json | Write-Host
Write-Host ''
Write-Host 'sshd service:' -ForegroundColor Yellow
$sshd | ConvertTo-Json | Write-Host
Write-Host ''
Write-Host 'Hypotheses:' -ForegroundColor Yellow
$hypotheses | ForEach-Object { Write-Host " - $_" }
Write-Host ''
Write-Host "JSON report : $jsonPath" -ForegroundColor Green
Write-Host "Log excerpts: $excerptPath" -ForegroundColor Green
Write-Host 'Reminder: do NOT re-run install-openssh-server.ps1 until root cause is confirmed.' -ForegroundColor Magenta
Write-Host 'Press Enter to close this window.'
Read-Host | Out-Null
