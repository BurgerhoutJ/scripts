<#
.SYNOPSIS
    Detects whether Dev Home is installed for the current user.
.DESCRIPTION
    Searches the current user's AppX packages for names matching *DevHome*.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify users with the unwanted Dev Home application installed.
    What it does: Returns exit code 1 when Dev Home is found; otherwise returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-DevHome.ps1
#>

if (Get-AppxPackage -Name *DevHome*) {
write-host "Dev Home found."

exit 1
}

else {
write-host "Dev Home not found."

exit 0
}