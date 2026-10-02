<#
.SYNOPSIS
    Detects whether the current user uses 24-hour time formats.
.DESCRIPTION
    Checks the current user's short and long time formats in the registry.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify users whose time formats do not use a 24-hour clock.
    What it does: Returns exit code 0 for HH:mm and HH:mm:ss; otherwise returns exit code 1.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-24hclock.ps1
#>

# Detection Script
# Define the desired values for the registry keys
$desiredShortTimeFormat = "HH:mm"
$desiredLongTimeFormat = "HH:mm:ss"

# Retrieve the current values of the registry keys
$currentShortTimeFormat = (Get-ItemProperty -Path "HKCU:\Control Panel\International" -Name sShortTime).sShortTime
$currentLongTimeFormat = (Get-ItemProperty -Path "HKCU:\Control Panel\International" -Name sTimeFormat).sTimeFormat

# Check if both values match the desired settings
if (($currentShortTimeFormat -eq $desiredShortTimeFormat) -and ($currentLongTimeFormat -eq $desiredLongTimeFormat)) {
    # Compliant
    exit 0
} else {
    # Non-compliant
    exit 1
}
