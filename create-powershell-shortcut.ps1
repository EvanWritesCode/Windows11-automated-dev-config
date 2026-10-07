#Creates a powershell shortcut with script execution and admin elevation and writes it to the desktop

# Get path to Desktop and the target repository directory
$desktopPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "PowerShell Admin Setup.lnk")
$repoRoot    = $PSScriptRoot

# 1. Create the .lnk shortcut using WScript.Shell
$wshShell = New-Object -ComObject WScript.Shell
$shortcut = $wshShell.CreateShortcut($desktopPath)
$shortcut.TargetPath       = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
# Or use "pwsh.exe" if your environment uses PowerShell 7
$shortcut.Arguments        = "-NoExit -ExecutionPolicy Bypass"
$shortcut.WorkingDirectory = $repoRoot
$shortcut.Description      = "Launch Elevated PowerShell with Execution Policy Bypass"
$shortcut.Save()

# 2. Set the "Run as Administrator" byte flag
# Byte 0x15 controls run-time flags; bit 0x20 (decimal 32) forces Run as Admin
$bytes = [System.IO.File]::ReadAllBytes($desktopPath)
$bytes[0x15] = $bytes[0x15] -bor 0x20
[System.IO.File]::WriteAllBytes($desktopPath, $bytes)

Write-Host "Shortcut created on Desktop with Administrator elevation enabled." -ForegroundColor Green
