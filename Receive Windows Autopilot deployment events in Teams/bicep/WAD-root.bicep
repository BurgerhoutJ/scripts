param workflows_ReceiveWindowsAutopilotdeploymenteventsinTeams_name string = 'ReceiveWindowsAutopilotdeploymenteventsinTeams'
param userAssignedIdentities_WAD_Identity_name string
param resourceLocation string

module managedIdentityDeployment 'WAD-managedidentity.bicep' = {
  name: 'managedIdentityDeployment'
  params: {
    userAssignedIdentities_WAD_Identity_name: userAssignedIdentities_WAD_Identity_name
    resourceLocation: resourceLocation
  }
}

module MainDeployment 'WAD-logicapps.bicep' = {
  name: 'MainDeployment'
  params: {
    resourceLocation: resourceLocation
    userAssignedIdentities_WAD_Identity_name: userAssignedIdentities_WAD_Identity_name
    workflows_ReceiveWindowsAutopilotdeploymenteventsinTeams_name:workflows_ReceiveWindowsAutopilotdeploymenteventsinTeams_name


  }
  dependsOn: [

    managedIdentityDeployment                                                       
  ]
}
