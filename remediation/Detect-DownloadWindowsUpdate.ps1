<#
.SYNOPSIS
    Triggers a Windows Update scan and download through Intune remediation.
.DESCRIPTION
    Always exits 1 to run the remediation script, including during post-detection.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Trigger an update scan and download on managed Windows devices.
    What it does: Returns exit code 1 on every run so the remediation script executes.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Exit 1 = Remediation will run (intentional, including during post-detection)
#>

Write-Output "Windows Update scan and download requested."
exit 1