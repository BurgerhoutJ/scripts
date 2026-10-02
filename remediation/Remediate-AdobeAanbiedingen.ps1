<#
.SYNOPSIS
    Removes the Adobe Aanbiedingen shortcut from the shared Start menu.
.DESCRIPTION
    Removes Aanbiedingen.lnk from the all-users Start menu Programs folder.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Remove the unwanted Adobe offers shortcut from managed Windows devices.
    What it does: Deletes the shared Start menu shortcut using Remove-Item.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-AdobeAanbiedingen.ps1
#>

Remove-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Aanbiedingen.lnk"