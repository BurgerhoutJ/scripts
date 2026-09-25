<#
.SYNOPSIS
    Detects whether the Windows Spotlight desktop icon is hidden.
.DESCRIPTION
    Checks the current user's Explorer desktop icon settings. Returns exit
    code 1 when the "Learn about this picture" icon is visible so Intune can
    run the remediation script. Returns exit code 0 when it is hidden.

    Creator: Jeroen Burgerhout
    Date: 2026-09-25
    Why: Remove the Windows Spotlight "Learn about this picture" desktop icon.
    What it does: Checks the per-user HideDesktopIcons registry value for the Spotlight icon.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes
.NOTES
    Pair with Remediate-HideWindowsSpotlightIcon.ps1 as the remediation script.
#>

$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
$valueName = '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}'

$value = Get-ItemProperty -Path $registryPath -Name $valueName -ErrorAction SilentlyContinue

if ($null -ne $value -and $value.$valueName -eq 1) {
    Write-Output 'Windows Spotlight desktop icon is hidden.'
    exit 0
}

Write-Output 'Windows Spotlight desktop icon is visible.'
exit 1
