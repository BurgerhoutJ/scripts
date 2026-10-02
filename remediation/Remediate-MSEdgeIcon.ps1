<#
.SYNOPSIS
    Removes the Microsoft Edge shortcut from the public desktop.
.DESCRIPTION
    Removes Microsoft Edge.lnk from the public desktop without uninstalling Microsoft Edge.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Remove the unwanted shared Microsoft Edge desktop shortcut from managed Windows devices.
    What it does: Deletes the public desktop shortcut using Remove-Item.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-MSEdgeIcon.ps1
#>

Remove-Item -Path "C:\Users\Public\Desktop\Microsoft Edge.lnk"