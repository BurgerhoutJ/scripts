<#
Run this ONCE, interactively, as a Global Administrator or Privileged Role
Administrator. It grants the Automation Account's system-assigned managed
identity the Graph application permissions the runbook needs:
  - DeviceManagementConfiguration.ReadWrite.All (compliance policies)
  - DeviceManagementApps.ReadWrite.All (app protection policies)

Find the managed identity's Object ID on the Automation Account blade in the
Azure Portal: Automation Account > Identity > System assigned > Object (principal) ID.
#>

#Requires -Modules Microsoft.Graph.Applications

param(
    [Parameter(Mandatory)] [string] $AutomationAccountManagedIdentityObjectId
)

Connect-MgGraph -Scopes 'AppRoleAssignment.ReadWrite.All', 'Application.Read.All'

$graphSp = Get-MgServicePrincipal -Filter "appId eq '00000003-0000-0000-c000-000000000000'"

$roleNames = @(
    'DeviceManagementConfiguration.ReadWrite.All',
    'DeviceManagementApps.ReadWrite.All'
)

foreach ($roleName in $roleNames) {
    $appRole = $graphSp.AppRoles | Where-Object {
        $_.Value -eq $roleName -and $_.AllowedMemberTypes -contains 'Application'
    }
    if (-not $appRole) {
        Write-Warning "Could not find app role '$roleName' - skipping."
        continue
    }

    try {
        New-MgServicePrincipalAppRoleAssignment `
            -ServicePrincipalId $AutomationAccountManagedIdentityObjectId `
            -PrincipalId $AutomationAccountManagedIdentityObjectId `
            -ResourceId $graphSp.Id `
            -AppRoleId $appRole.Id | Out-Null
        Write-Output "Granted $roleName to managed identity $AutomationAccountManagedIdentityObjectId."
    } catch {
        if ($_.Exception.Message -match 'already exists') {
            Write-Output "Already granted: $roleName"
        } else { throw }
    }
}
