<#
.SYNOPSIS
    Configures 24-hour time formats for the current user.
.DESCRIPTION
    Updates the current user's short and long time formats in the registry.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Use consistent 24-hour time formats on managed Windows devices.
    What it does: Sets sShortTime to HH:mm and sTimeFormat to HH:mm:ss, then returns exit code 0.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-24hclock.ps1
#>

# Remediation Script
Write-Host "Setting Short time format"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime -Value "HH:mm"

Write-Host "Setting Long time format"
Set-ItemProperty -Path "HKCU:\Control Panel\International" -Name sTimeFormat -Value "HH:mm:ss"

# Exit with code 0 to indicate successful remediation
exit 0
