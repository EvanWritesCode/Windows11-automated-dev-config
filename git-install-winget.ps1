# Requires -RunAsAdministrator
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#.\git-install-winget.ps1

Write-Host "==> Checking administrative privileges..." -ForegroundColor Cyan
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Please run this script from an elevated PowerShell prompt (Run as Administrator)."
    exit 1
}

# 1. Check if Git is already installed
Write-Host "==> Checking if Git is already installed..." -ForegroundColor Cyan
if (Get-Command git -ErrorAction SilentlyContinue) {
    $currentVersion = git --version
    Write-Host "Git is already installed: $currentVersion" -ForegroundColor Yellow
    exit 0
}

# 2. Install Git via Winget
Write-Host "==> Installing Git for Windows via Winget..." -ForegroundColor Cyan
$installArgs = @(
    "install",
    "--id", "Git.Git",
    "-e",
    "--source", "winget",
    "--silent",
    "--accept-source-agreements",
    "--accept-package-agreements"
)

$process = Start-Process -FilePath "winget.exe" -ArgumentList $installArgs -NoNewWindow -Wait -PassThru

if ($process.ExitCode -ne 0) {
    Write-Error "Winget installation failed with exit code $($process.ExitCode)."
    exit $process.ExitCode
}

# 3. Refresh PATH in current session
Write-Host "==> Updating environment PATH in the current session..." -ForegroundColor Cyan
$machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$env:Path = "$machinePath;$userPath"

# 4. Verify installation
if (Get-Command git -ErrorAction SilentlyContinue) {
    $installedVersion = git --version
    Write-Host "==> Successfully installed: $installedVersion" -ForegroundColor Green
} else {
    Write-Warning "Installation finished, but Git was not detected in the current PATH. Restart your terminal session."
}
