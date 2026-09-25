<#
.SYNOPSIS
    Detects whether 24 hclock is configured correctly.
.DESCRIPTION
    Checks the current device state and exits 0 when compliant; otherwise exits 1 so policy enforcement can run the remediation script.
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
