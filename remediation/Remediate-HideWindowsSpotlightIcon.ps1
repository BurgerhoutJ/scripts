<#
.SYNOPSIS
    Hides the Windows Spotlight desktop icon for the current user.
.DESCRIPTION
    Sets the per-user Explorer registry value that hides the Windows Spotlight
    "Learn about this picture" desktop icon without disabling Windows Spotlight.

    Creator: Jeroen Burgerhout
    Date: 2026-09-25
    Why: Remove the Windows Spotlight desktop icon while keeping Spotlight backgrounds enabled.
    What it does: Creates or updates the HideDesktopIcons registry value to 1.

    Intune settings:
      - Run this script using the logged-on credentials: Yes
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes
.NOTES
    Pair with Detect-HideWindowsSpotlightIcon.ps1 as the detection script.
    The icon may require Explorer to refresh, or the user to sign out and back in.
#>

$registryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'
$valueName = '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}'

try {
    if (-not (Test-Path -Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }

    New-ItemProperty -Path $registryPath -Name $valueName -PropertyType DWord -Value 1 -Force | Out-Null
    Write-Output 'Windows Spotlight desktop icon is now hidden. Sign out or restart Windows Explorer if it remains visible.'
    exit 0
}
catch {
    Write-Error "Failed to hide the Windows Spotlight desktop icon: $($_.Exception.Message)"
    exit 1
}
