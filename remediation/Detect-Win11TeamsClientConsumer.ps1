<#
.SYNOPSIS
    Detects whether consumer Microsoft Teams is installed for the current user.
.DESCRIPTION
    Searches the current user's AppX packages for names matching *MicrosoftTeams*.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify users with the unwanted consumer Microsoft Teams package installed.
    What it does: Returns exit code 1 when the package is found; otherwise returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-Win11TeamsClientConsumer.ps1
#>

if (Get-AppxPackage -Name *MicrosoftTeams*) {
write-host "Microsoft Consumer Teams found."

exit 1
}

else {
write-host "Microsoft Consumer Teams not found."

exit 0
}