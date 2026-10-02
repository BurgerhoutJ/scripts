<#
.SYNOPSIS
    Detects the Adobe Aanbiedingen shortcut in the shared Start menu.
.DESCRIPTION
    Checks for Aanbiedingen.lnk in the all-users Start menu Programs folder.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify devices with the unwanted Adobe offers shortcut.
    What it does: Returns exit code 1 when the shortcut exists; otherwise returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-AdobeAanbiedingen.ps1
#>

$msedge= Get-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Aanbiedingen.lnk"

if ($msedge){
    Write-Output "AdobeA anbiedingen shortcut found"
    Exit 1
}
else {
    Write-Output "Adobe Aanbiedingen shortcut not found"
    Exit 0
}