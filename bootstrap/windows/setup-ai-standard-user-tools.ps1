[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$expectedUser = 'ai_standard_user'

if ($env:USERNAME -ne $expectedUser) {
    Write-Host "This setup must be run while signed in as $expectedUser." -ForegroundColor Yellow
    Write-Host "Current user: $env:USERNAME"
    Read-Host 'Press Enter to close'
    exit 1
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdministrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdministrator) {
    Write-Host 'Safety check failed: this account is running with administrator privileges.' -ForegroundColor Red
    Read-Host 'Press Enter to close'
    exit 1
}

Write-Host 'Installing 1Password for the standard-user profile...'
$winget = Get-Command winget.exe -ErrorAction SilentlyContinue
if ($winget) {
    & $winget.Source install --id AgileBits.1Password --exact --scope user --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "1Password installation returned exit code $LASTEXITCODE. You can retry it later from this launcher."
    }
} else {
    Write-Warning 'winget is unavailable. Opening the Microsoft Store so 1Password can be installed there.'
    Start-Process 'ms-windows-store://search/?query=1Password'
}

$codex = Get-AppxPackage -Name OpenAI.Codex -ErrorAction SilentlyContinue
if (-not $codex) {
    Write-Host 'Opening the Microsoft Store page for OpenAI Codex...'
    Start-Process 'ms-windows-store://search/?query=OpenAI%20Codex'
    Write-Host 'In Microsoft Store, select the official OpenAI Codex app and choose Install.' -ForegroundColor Cyan
} else {
    Write-Host "OpenAI Codex is already registered for $expectedUser." -ForegroundColor Green
}

Write-Host ''
Write-Host 'One-time actions:' -ForegroundColor Cyan
Write-Host '1. Sign in to 1Password and complete device authorization.'
Write-Host '2. Install OpenAI Codex from the Store window if it is not already installed.'
Write-Host '3. Open Codex and sign in with your existing ChatGPT account.'
Write-Host 'No Windows password or application token was saved by this script.' -ForegroundColor Green
Read-Host 'Press Enter after the Store installation has started'
