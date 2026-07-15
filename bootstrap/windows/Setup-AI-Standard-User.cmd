@echo off
setlocal
set "setupScript=%~dp0setup-ai-standard-user-tools.ps1"
if not exist "%setupScript%" set "setupScript=%PUBLIC%\Documents\AI Workstation\setup-ai-standard-user-tools.ps1"
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%setupScript%"
endlocal
