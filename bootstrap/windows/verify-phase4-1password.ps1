[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$expectedUser = 'ai_non_Admin_260712'

if ($env:USERNAME -ne $expectedUser) {
    throw "Run this verification as $expectedUser. Current user: $env:USERNAME"
}

$isAdmin = ([Security.Principal.WindowsPrincipal]::new(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$onePassword = Get-Command 1Password.exe -ErrorAction SilentlyContinue
$op = Get-Command op.exe -ErrorAction SilentlyContinue

[pscustomobject]@{
    User = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    IsAdministrator = $isAdmin
    OnePasswordAppInstalled = [bool]$onePassword
    OnePasswordCliInstalled = [bool]$op
    OnePasswordCliVersion = if ($op) { (& $op.Source --version) } else { $null }
    PrivateKeyContentChecked = $false
}

if (-not $onePassword -or -not $op -or $isAdmin) {
    exit 1
}
