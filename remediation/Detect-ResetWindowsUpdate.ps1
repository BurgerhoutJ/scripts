<#
.SYNOPSIS
    Triggers a Windows Update reset through Intune remediation.
.DESCRIPTION
    Always requests the paired Windows Update reset remediation without checking device state.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Trigger the Windows Update reset procedure on targeted devices.
    What it does: Writes a trigger message and returns exit code 1 on every run, including post-detection.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-ResetWindowsUpdate.ps1
    Original author: JOrgen Nilsson (ccmexec.com)
#>

# Always trigger
Write-Host "Script will always be triggered"
exit 1