<#
.SYNOPSIS
    Detects the Microsoft Edge shortcut on the public desktop.
.DESCRIPTION
    Checks for Microsoft Edge.lnk in the public desktop folder.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify devices with the unwanted shared Microsoft Edge desktop shortcut.
    What it does: Returns exit code 1 when the shortcut exists; otherwise returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-MSEdgeIcon.ps1
#>

$msedge= Get-Item -Path "C:\Users\Public\Desktop\Microsoft Edge.lnk"

if ($msedge){
    Write-Output "MS Edge shortcut found"
    Exit 1
}
else {
    Write-Output "MS Edge shortcut is not found"
    Exit 0
}