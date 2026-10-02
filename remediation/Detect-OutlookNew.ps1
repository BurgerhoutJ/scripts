<#
.SYNOPSIS
    Detects whether the new Outlook is installed for the current user.
.DESCRIPTION
    Searches the current user's AppX packages for names matching *OutlookForWindows*.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify users with the unwanted new Outlook application installed.
    What it does: Returns exit code 1 when new Outlook is found; otherwise returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-OutlookNew.ps1
#>

if (Get-AppxPackage -Name *OutlookForWindows*) {
write-host "Microsoft Outlook (New) found."

exit 1
}

else {
write-host "Microsoft Outlook (New) not found."

exit 0
}