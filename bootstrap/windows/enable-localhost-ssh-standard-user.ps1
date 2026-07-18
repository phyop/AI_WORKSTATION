[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$expectedUser = 'ai_non_Admin_260712'
$publicKey = 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBy2M8Sebt/zE6KclquQxNKWZGODJkn5mrD7dd2SBa+v local-codex-to-ai_non_Admin_260712@TXAR'
$authorizedLine = 'from="127.0.0.1,::1",no-agent-forwarding,no-port-forwarding,no-user-rc,no-X11-forwarding ' + $publicKey

if ($env:USERNAME -ne $expectedUser) {
    Write-Host "Run this file while signed in as $expectedUser." -ForegroundColor Yellow
    Write-Host "Current user: $env:USERNAME"
    Read-Host 'Press Enter to close'
    exit 1
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Safety check failed: this account is running as an administrator.' -ForegroundColor Red
    Read-Host 'Press Enter to close'
    exit 1
}

$sshDir = Join-Path $HOME '.ssh'
$authorizedKeys = Join-Path $sshDir 'authorized_keys'
New-Item -ItemType Directory -Path $sshDir -Force | Out-Null

$existing = if (Test-Path -LiteralPath $authorizedKeys) {
    @(Get-Content -LiteralPath $authorizedKeys)
} else {
    @()
}

if ($existing -contains $authorizedLine) {
    Write-Host 'The localhost key is already authorized.' -ForegroundColor Green
} else {
    $entry = $authorizedLine + [Environment]::NewLine
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    if (Test-Path -LiteralPath $authorizedKeys) {
        [System.IO.File]::AppendAllText($authorizedKeys, $entry, $utf8NoBom)
    } else {
        [System.IO.File]::WriteAllText($authorizedKeys, $entry, $utf8NoBom)
    }
    Write-Host 'The localhost key was added without changing other authorized keys.' -ForegroundColor Green
}

Write-Host 'Restriction: localhost only; agent, port, X11, and user-rc forwarding disabled.'
Write-Host 'Fingerprint: SHA256:b4EPQFbnEqAEQyCVZFE7Ea3NKX5LvixjHhMNeRqEU5k'
Read-Host 'Press Enter to close'
