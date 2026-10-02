<#
.SYNOPSIS
    Detects whether Windows Mail and Calendar is installed for the current user.
.DESCRIPTION
    Searches the current user's AppX packages for microsoft.windowscommunicationsapps.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify users with the legacy Windows Mail and Calendar application installed.
    What it does: Returns exit code 1 when the package is found; otherwise returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-MailApp.ps1
#>

$mailapp= Get-AppxPackage -Name *microsoft.windowscommunicationsapps*

if ($mailapp){
    Write-Output "Windows Mail app is aanwezig"
    Exit 1
}
else {
    Write-Output "Windows Mail app is niet aanwezig"
    Exit 0
}