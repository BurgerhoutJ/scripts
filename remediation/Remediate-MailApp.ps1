<#
.SYNOPSIS
    Removes Windows Mail and Calendar for the current user.
.DESCRIPTION
    Finds and removes the current user's microsoft.windowscommunicationsapps package.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Remove the legacy Windows Mail and Calendar application from managed Windows user profiles.
    What it does: Pipes matching AppX packages to Remove-AppxPackage.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-MailApp.ps1
#>

Get-AppxPackage *microsoft.windowscommunicationsapps* | Remove-AppxPackage