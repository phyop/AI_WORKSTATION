#Requires -RunAsAdministrator
[CmdletBinding()]
param(
  [string]$Peer = 'time.windows.com,0x9'
)

$ErrorActionPreference = 'Stop'

Write-Host "Configuring Windows Time peer: $Peer"
& w32tm.exe /config /syncfromflags:manual /manualpeerlist:$Peer /update
if ($LASTEXITCODE -ne 0) { throw "w32tm config failed: $LASTEXITCODE" }

Restart-Service W32Time
& w32tm.exe /resync /force
if ($LASTEXITCODE -ne 0) { throw "w32tm resync failed: $LASTEXITCODE" }

Start-Sleep -Seconds 3
& w32tm.exe /query /status
& w32tm.exe /query /source
