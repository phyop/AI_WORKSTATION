#Requires -RunAsAdministrator
[CmdletBinding()]
param(
  [ValidatePattern('^[A-Za-z0-9_-]{1,20}$')]
  [string]$UserName = 'ai_standard_user',
  [string]$FullName = 'AI Workstation Standard User'
)

$ErrorActionPreference = 'Stop'

$existing = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
if (-not $existing) {
  Write-Host "Create local standard user: $UserName" -ForegroundColor Cyan
  $created = $false
  for ($attempt = 1; $attempt -le 3 -and -not $created; $attempt++) {
    $password = Read-Host 'Enter a strong initial password (input is hidden)' -AsSecureString
    $confirmation = Read-Host 'Enter the same password again' -AsSecureString
    $passwordText = [System.Net.NetworkCredential]::new('', $password).Password
    $confirmationText = [System.Net.NetworkCredential]::new('', $confirmation).Password
    try {
      if ($passwordText -cne $confirmationText) { throw 'Passwords do not match.' }
      New-LocalUser -Name $UserName -FullName $FullName `
        -Description 'Standard AI Workstation development account.' `
        -Password $password -PasswordNeverExpires:$false -UserMayNotChangePassword:$false | Out-Null
      $created = $true
    } catch {
      Write-Host "Account creation attempt $attempt failed: $($_.Exception.Message)" -ForegroundColor Red
      if ($attempt -eq 3) {
        Write-Host 'Press Enter to close this window.'
        Read-Host | Out-Null
        throw
      }
    } finally {
      $passwordText = $null
      $confirmationText = $null
      $password = $null
      $confirmation = $null
    }
  }
} else {
  Write-Host "User already exists; group membership will be verified: $UserName" -ForegroundColor Yellow
}

$usersGroup = (Get-LocalGroup -SID 'S-1-5-32-545').Name
$adminsGroup = (Get-LocalGroup -SID 'S-1-5-32-544').Name
$qualifiedName = "$env:COMPUTERNAME\$UserName"

& net.exe user $UserName /passwordreq:yes | Out-Null
if ($LASTEXITCODE -ne 0) { throw "Unable to require a password for the account: $LASTEXITCODE" }

if (-not (Get-LocalGroupMember -Group $usersGroup -ErrorAction Stop | Where-Object Name -eq $qualifiedName)) {
  Add-LocalGroupMember -Group $usersGroup -Member $UserName
}

if (Get-LocalGroupMember -Group $adminsGroup -ErrorAction Stop | Where-Object Name -eq $qualifiedName) {
  Remove-LocalGroupMember -Group $adminsGroup -Member $UserName
}

$user = Get-LocalUser -Name $UserName
$isUser = [bool](Get-LocalGroupMember -Group $usersGroup | Where-Object Name -eq $qualifiedName)
$isAdmin = [bool](Get-LocalGroupMember -Group $adminsGroup | Where-Object Name -eq $qualifiedName)

if (-not $user.Enabled -or -not $isUser -or $isAdmin) {
  throw "Account verification failed. Enabled=$($user.Enabled), Users=$isUser, Administrators=$isAdmin"
}

Write-Host "Account verified: $qualifiedName" -ForegroundColor Green
Write-Host 'Role: standard user (not an Administrator)' -ForegroundColor Green
Write-Host 'Press Enter to close this window.'
Read-Host | Out-Null
