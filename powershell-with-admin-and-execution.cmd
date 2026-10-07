@echo off
:: Check for admin rights and self-elevate via UAC if not elevated
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -NoProfile -Command "Start-Process cmd -ArgumentList '/c \"%~dp0%~nx0\"' -Verb RunAs"
    exit /b
)

:: Once elevated, launch PowerShell in the repo's directory
cd /d "%~dp0"
start powershell.exe -NoExit -ExecutionPolicy Bypass
