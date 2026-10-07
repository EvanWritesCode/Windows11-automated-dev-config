# Requires -RunAsAdministrator
# to run:  
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#.\git-install-standalone.ps1

Write-Host "==> Checking administrative privileges..." -ForegroundColor Cyan
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Please run this script from an elevated PowerShell prompt."
    exit 1
}

# Check existing installation
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "Git is already installed: $(git --version)" -ForegroundColor Yellow
    exit 0
}

# 1. Fetch latest Git for Windows release download URL via GitHub API
Write-Host "==> Fetching latest 64-bit installer URL from GitHub..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$apiUrl = "https://api.github.com/repos/git-for-windows/git/releases/latest"
$release = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
$asset = $release.assets | Where-Object { $_.name -match '^Git-.*-64-bit\.exe$' } | Select-Object -First 1

if (-not $asset) {
    Write-Error "Failed to locate 64-bit installer asset."
    exit 1
}

$installerUrl = $asset.browser_download_url
$tempInstaller = Join-Path -Path $env:TEMP -ChildPath $asset.name

# 2. Download Installer
Write-Host "==> Downloading $($asset.name)..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $installerUrl -OutFile $tempInstaller -UseBasicParsing

# 3. Run Silent Install
# /VERYSILENT /NORESTART suppresses UI and prevents unexpected reboots.
Write-Host "==> Executing silent installation..." -ForegroundColor Cyan
$installProcess = Start-Process -FilePath $tempInstaller -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS" -Wait -PassThru

# Clean up installer file
Remove-Item -Path $tempInstaller -Force -ErrorAction SilentlyContinue

if ($installProcess.ExitCode -ne 0) {
    Write-Error "Installer exited with error code $($installProcess.ExitCode)."
    exit $installProcess.ExitCode
}

# 4. Refresh session PATH
$machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$env:Path = "$machinePath;$userPath"

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "==> Successfully installed: $(git --version)" -ForegroundColor Green
} else {
    Write-Warning "Installation complete. Restart your PowerShell terminal to reload PATH."
}
