<#
.SYNOPSIS
    Detects whether the configured Entra ID SIDs are local administrators.
.DESCRIPTION
    Uses ADSI to compare local Administrators member names with two configured Entra ID SIDs.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Identify devices missing the configured tenant administrator entries in local Administrators.
    What it does: Returns exit code 0 when both SID strings are found; otherwise returns exit code 1.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Detect-TenantAdministrators.ps1
#>

# Define the Entra ID SIDs to check
# Replace these with your actual Entra ID SIDs
$EntraIDSID1 = "S-1-12-1-2006554087-1077730195-384167608-1848081268"  # Azure AD Joined Device Local Administrator
$EntraIDSID2 = "S-1-12-1-180637778-1132252887-4221403304-2124284756"  # Global Administrator

# Get the local Administrators group
$AdministratorsGroup = [ADSI]"WinNT://./Administrators"

# Function to check if SID is in the Local Administrators group
function Is-SIDInAdministratorsGroup {
    param ([string]$SID)
    $Members = $AdministratorsGroup.PSBase.Invoke("Members") | ForEach-Object {
        $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
    }
    return $Members -contains $SID
}

# Check if the SIDs are already in the Administrators group
$SID1InAdminGroup = Is-SIDInAdministratorsGroup -SID $EntraIDSID1
$SID2InAdminGroup = Is-SIDInAdministratorsGroup -SID $EntraIDSID2

# Output results for Intune compliance
if ($SID1InAdminGroup -and $SID2InAdminGroup) {
    Write-Output "Both Entra ID SIDs are in the Local Administrators group."
    exit 0  # Compliant
} else {
    Write-Output "One or both Entra ID SIDs are NOT in the Local Administrators group."
    exit 1  # Non-compliant
}
