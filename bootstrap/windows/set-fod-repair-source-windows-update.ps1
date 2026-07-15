#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Set Features on Demand repair source to Windows Update (RepairContentServerSource=2).

.DESCRIPTION
  Intended for OpenSSH Server FoD HRESULT 0x800f0954 when CBS pending is already clear.
  Does NOT install OpenSSH, start sshd, or change firewall.

  Safety:
    - Refuses to run unless -Approve is supplied AND you type YES
    - Writes before/after audit JSON under %ProgramData%\AIWorkstation
#>
[CmdletBinding()]
param(
  [switch]$Approve
)

$ErrorActionPreference = 'Stop'
$reportDir = Join-Path $env:ProgramData 'AIWorkstation'
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$auditPath = Join-Path $reportDir 'openssh-fod-repair-source-audit.json'
$servicingPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Servicing'

function Get-RepairSourceValue {
  if (-not (Test-Path -LiteralPath $servicingPath)) {
    return $null
  }
  try {
    return (Get-ItemProperty -LiteralPath $servicingPath -Name RepairContentServerSource -ErrorAction Stop).RepairContentServerSource
  } catch {
    return $null
  }
}

Write-Host '=== Set FoD RepairContentServerSource=2 (Windows Update) ===' -ForegroundColor Cyan
Write-Host 'This changes HKLM servicing policy only. It does not install OpenSSH.' -ForegroundColor Yellow

if (-not $Approve) {
  throw @"
Refusing to change registry without -Approve.

Review docs\troubleshooting\openssh-capability-stuck.md first, then run:
  .\set-fod-repair-source-windows-update.ps1 -Approve
"@
}

$before = Get-RepairSourceValue
Write-Host ("Current RepairContentServerSource: {0}" -f ($(if ($null -eq $before) { '(not set)' } else { $before })))

$answer = Read-Host 'Type YES to set RepairContentServerSource=2'
if ($answer -ne 'YES') {
  throw 'Cancelled; registry not changed.'
}

if (-not (Test-Path -LiteralPath $servicingPath)) {
  New-Item -Path $servicingPath -Force | Out-Null
}
New-ItemProperty -Path $servicingPath -Name RepairContentServerSource -PropertyType DWord -Value 2 -Force | Out-Null

$after = Get-RepairSourceValue
$audit = [ordered]@{
  changed_at = (Get-Date).ToString('o')
  computer_name = $env:COMPUTERNAME
  path = $servicingPath
  value_name = 'RepairContentServerSource'
  before = $before
  after = $after
  expected = 2
  did_not_run = @(
    'Add-WindowsCapability',
    'firewall changes',
    'service start/stop'
  )
  next_actions = @(
    'Re-run diagnose-openssh-dism-cbs.ps1 and confirm any_pending=false.',
    'Then run install-openssh-server.ps1 once, or install OpenSSH Server from Optional Features UI.',
    'To revert this policy value later: Remove-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Servicing -Name RepairContentServerSource'
  )
}
$audit | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $auditPath -Encoding UTF8

if ($after -ne 2) {
  throw ("Failed to set RepairContentServerSource; after={0}. Audit: {1}" -f $after, $auditPath)
}

Write-Host 'RepairContentServerSource is now 2.' -ForegroundColor Green
Write-Host "Audit: $auditPath" -ForegroundColor Green
Write-Host 'Next: confirm pending is still false, then install OpenSSH Server once.' -ForegroundColor Magenta
Write-Host 'Press Enter to close this window.'
Read-Host | Out-Null
