<#
.SYNOPSIS
    Adds the configured Entra ID SIDs to local Administrators.
.DESCRIPTION
    Uses ADSI to check two configured Entra ID SIDs and add missing entries to local Administrators.

    Creator: Jeroen Burgerhout
    Date: 2026-10-02
    Why: Apply the configured tenant administrator membership to targeted Windows devices.
    What it does: Checks each configured SID string and adds entries that are not found in the group listing.

    Intune settings:
      - Run this script using the logged-on credentials: No
      - Enforce script signature check: No
      - Run script in 64-bit PowerShell host: Yes

.NOTES
    Script: Remediate-TenantAdministrators.ps1
#>

# Define the Entra ID SIDs to add
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

# Function to add SID to the Local Administrators group
function Add-SIDToAdministratorsGroup {
    param ([string]$SID)
    $User = [ADSI]"WinNT://$SID,user"
    $AdministratorsGroup.PSBase.Invoke("Add", $User.PSBase.Path)
    Write-Output "$SID has been added to the Local Administrators group."
}

# Check if the SIDs are already in the Administrators group and add them if necessary
$SID1InAdminGroup = Is-SIDInAdministratorsGroup -SID $EntraIDSID1
$SID2InAdminGroup = Is-SIDInAdministratorsGroup -SID $EntraIDSID2

if (-not $SID1InAdminGroup) {
    Add-SIDToAdministratorsGroup -SID $EntraIDSID1
} else {
    Write-Output "Entra ID SID1 is already in the Local Administrators group."
}

if (-not $SID2InAdminGroup) {
    Add-SIDToAdministratorsGroup -SID $EntraIDSID2
} else {
    Write-Output "Entra ID SID2 is already in the Local Administrators group."
}
