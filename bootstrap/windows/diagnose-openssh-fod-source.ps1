#Requires -RunAsAdministrator
<#
.SYNOPSIS
  Read-only check for Features on Demand / Windows Update source (OpenSSH 0x800f0954).

.DESCRIPTION
  Does not change registry, policies, firewall, or install OpenSSH.
  Writes: %ProgramData%\AIWorkstation\openssh-fod-source-diagnose.json
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Continue'
$reportDir = Join-Path $env:ProgramData 'AIWorkstation'
New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
$jsonPath = Join-Path $reportDir 'openssh-fod-source-diagnose.json'

function Get-PropBag {
  param([string]$Path)
  $result = [ordered]@{
    path = $Path
    exists = Test-Path -LiteralPath $Path
    properties = [ordered]@{}
  }
  if (-not $result.exists) {
    return $result
  }
  try {
    $item = Get-ItemProperty -LiteralPath $Path -ErrorAction Stop
    foreach ($p in $item.PSObject.Properties) {
      if ($p.Name -in @('PSPath', 'PSParentPath', 'PSChildName', 'PSDrive', 'PSProvider')) {
        continue
      }
      $result.properties[$p.Name] = [string]$p.Value
    }
  } catch {
    $result.error = $_.Exception.Message
  }
  return $result
}

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

Write-Host '=== OpenSSH FoD / WU source read-only diagnose ===' -ForegroundColor Cyan

$wuPolicy = Get-PropBag 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'
$wuAU = Get-PropBag 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU'
$servicing = Get-PropBag 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Servicing'
$wuService = Get-SafeService -Name 'wuauserv'
$bits = Get-SafeService -Name 'BITS'
$doSvc = Get-SafeService -Name 'DoSvc'

$notes = New-Object System.Collections.Generic.List[string]
$props = $wuPolicy.properties
$svcProps = $servicing.properties

if ($props.Contains('WUServer') -or $props.Contains('WUStatusServer')) {
  $notes.Add('WSUS server values are present under WindowsUpdate policy. FoD packages may be unavailable (HRESULT 0x800f0954).')
}
if ($props.Contains('DoNotConnectToInternetWindowsUpdateLocations') -and $props['DoNotConnectToInternetWindowsUpdateLocations'] -eq '1') {
  $notes.Add('DoNotConnectToInternetWindowsUpdateLocations=1 blocks online Windows Update content for optional features.')
}
if ($svcProps.Contains('RepairContentServerSource')) {
  $notes.Add(('RepairContentServerSource={0} (2 usually means use Windows Update for repair/FoD content).' -f $svcProps['RepairContentServerSource']))
} else {
  $notes.Add('RepairContentServerSource is not set. If CBS shows 0x800f0954, set it to 2 after explicit approval.')
}
if ($wuService.exists -and $wuService.status -ne 'Running') {
  $notes.Add(('wuauserv status is {0}; Windows Update service should be running for FoD download.' -f $wuService.status))
}
if ($notes.Count -eq 0) {
  $notes.Add('No obvious WSUS/FoD policy blocker in the checked keys; still review CBS excerpts for 0x800f0954 context.')
}

$report = [ordered]@{
  checked_at = (Get-Date).ToString('o')
  computer_name = $env:COMPUTERNAME
  mode = 'read-only-fod-source'
  did_not_run = @(
    'registry changes',
    'Add-WindowsCapability',
    'firewall changes'
  )
  windows_update_policy = $wuPolicy
  windows_update_au_policy = $wuAU
  servicing_policy = $servicing
  services = [ordered]@{
    wuauserv = $wuService
    bits = $bits
    dosvc = $doSvc
  }
  hypotheses = @($notes)
  next_actions = @(
    'If WSUS or DoNotConnectToInternetWindowsUpdateLocations blocks FoD, approve a servicing policy change (RepairContentServerSource=2) before retrying install once.',
    'Do not run install-openssh-server.ps1 until FoD source is fixed and pending remains false.',
    'Provide this JSON plus openssh-dism-cbs-excerpts.txt if 0x800f0954 context is still unclear.'
  )
}

$report | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $jsonPath -Encoding UTF8
Write-Host ($report | ConvertTo-Json -Depth 6)
Write-Host ''
Write-Host "JSON report: $jsonPath" -ForegroundColor Green
Write-Host 'Press Enter to close this window.'
Read-Host | Out-Null
