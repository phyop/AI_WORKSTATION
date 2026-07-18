@echo off
setlocal
set "setupScript=%~dp0enable-localhost-ssh-standard-user.ps1"
if not exist "%setupScript%" set "setupScript=%PUBLIC%\Documents\AI Workstation\enable-localhost-ssh-standard-user.ps1"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%setupScript%"
endlocal
