<#
.SYNOPSIS
    Resets Windows Update cache folders and restarts update services.
.DESCRIPTION
    Stops update-related services and renames SoftwareDistribution and catroot2 to backup folders.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Reset Windows Update components on targeted devices experiencing update issues.
    What it does: Replaces existing backup folders, renames update caches, restarts services, invokes wuauclt /updatenow, and returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-ResetWindowsUpdate.ps1
    Original author: JOrgen Nilsson (ccmexec.com)
    Does not verify whether the update request succeeds.
#>

$DependentService = Get-Service -name cryptsvc -DependentServices |Where-Object status -eq Started
if ($DependentService) {Stop-Service $DependentService -Force} 
Stop-Service -Name wuauserv 
Stop-Service -Name cryptsvc -Force
Stop-Service -Name bits -Force

if (Test-Path $Env:Windir\SoftwareDistribution.bak) {
    Remove-Item $Env:Windir\SoftwareDistribution.bak -Recurse -Force
    Rename-Item -Path $Env:Windir\SoftwareDistribution -NewName SoftwareDistribution.bak
} else {
    Rename-Item -Path $Env:Windir\SoftwareDistribution -NewName SoftwareDistribution.bak
}

if (Test-Path $Env:Windir\System32\catroot2.bak) {
    Remove-Item $Env:Windir\System32\catroot2.bak -Recurse -Force
    Rename-Item -Path $Env:Windir\System32\catroot2 -NewName catroot2.bak
} else {
    Rename-Item -Path $Env:Windir\System32\catroot2 -NewName catroot2.bak
}

Start-Service -Name cryptsvc 
Start-Service -Name bits 
Start-Service -Name wuauserv 
if ($DependentService) {Start-Service $DependentService}

wuauclt /updatenow
Exit 0