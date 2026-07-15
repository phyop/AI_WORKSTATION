#Requires -RunAsAdministrator
[CmdletBinding()]
param(
  # Use -ForcePendingBypass only after DISM/CBS diagnosis confirms it is safe.
  [switch]$ForcePendingBypass
)

$ErrorActionPreference = 'Stop'
$capabilityName = 'OpenSSH.Server~~~~0.0.1.0'
$reportDir = Join-Path $env:ProgramData 'AIWorkstation'
$reportPath = Join-Path $reportDir 'phase3-openssh.json'
$pendingXml = Join-Path $env:SystemRoot 'WinSxS\pending.xml'

New-Item -ItemType Directory -Path $reportDir -Force | Out-Null

$pendingSignals = @(
  (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'),
  (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'),
  (Test-Path -LiteralPath $pendingXml)
)
if (($pendingSignals -contains $true) -and -not $ForcePendingBypass) {
  throw @"
Refusing to install OpenSSH while Windows servicing is pending.
Run bootstrap\windows\diagnose-openssh-dism-cbs.ps1 first.
See docs\troubleshooting\openssh-capability-stuck.md
Re-run with -ForcePendingBypass only after DISM/CBS root cause is understood.
"@
}

$capability = Get-WindowsCapability -Online -Name $capabilityName
if ($capability.State -ne 'Installed') {
  Write-Host 'Installing Windows OpenSSH Server...' -ForegroundColor Cyan
  $capability = Add-WindowsCapability -Online -Name $capabilityName
}

Set-Service -Name sshd -StartupType Automatic
Start-Service -Name sshd

# Keep inbound access closed until Phase 4 installs and verifies a dedicated key.
$firewallRule = Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
if ($firewallRule) {
  Disable-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' | Out-Null
}

$service = Get-Service -Name sshd
$configPath = Join-Path $env:ProgramData 'ssh\sshd_config'
$result = [ordered]@{
  checked_at = (Get-Date).ToString('o')
  capability = (Get-WindowsCapability -Online -Name $capabilityName).State.ToString()
  service_status = $service.Status.ToString()
  service_start_type = $service.StartType.ToString()
  config_path = $configPath
  config_exists = Test-Path -LiteralPath $configPath
  inbound_firewall_enabled = [bool](Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue | Where-Object Enabled -eq 'True')
  security_gate = 'Inbound firewall remains disabled until SSH public-key verification.'
}

$result | ConvertTo-Json | Set-Content -LiteralPath $reportPath -Encoding UTF8
$result | Format-List
Write-Host "Audit report: $reportPath" -ForegroundColor Green
Write-Host 'Press Enter to close this window.'
Read-Host | Out-Null
