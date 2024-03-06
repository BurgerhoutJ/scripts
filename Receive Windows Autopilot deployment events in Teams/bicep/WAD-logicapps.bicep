param workflows_ReceiveWindowsAutopilotdeploymenteventsinTeams_name string
param resourceLocation string 
param userAssignedIdentities_WAD_Identity_name string = 'WAD-Identity'


resource workflows_ReceiveWindowsAutopilotdeploymenteventsinTeams_name_resource 'Microsoft.Logic/workflows@2019-05-01' = {
  name: workflows_ReceiveWindowsAutopilotdeploymenteventsinTeams_name
  location: resourceLocation
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities/',userAssignedIdentities_WAD_Identity_name)}': {}
    }
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {
        Recurrence: {
          recurrence: {
            frequency: 'Hour'
            interval: 1
          }
          evaluatedRecurrence: {
            frequency: 'Hour'
            interval: 1
          }
          type: 'Recurrence'
        }
      }
      actions: {
        For_each_deploymentState: {
          foreach: '@body(\'Parse_JSON_GET_autopilotEvents\')?[\'value\']'
          actions: {
            Condition: {
              actions: {
                For_each_windowsAutopilotDeviceIdentities: {
                  foreach: '@body(\'Parse_JSON_GET_windowsAutopilotDeviceIdentities\')?[\'value\']'
                  actions: {
                    HTTP_POST_Teams_webhook: {
                      runAfter: {}
                      type: 'Http'
                      inputs: {
                        authentication: {
                          audience: 'https://graph.microsoft.com/'
                          identity: resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedIdentities_WAD_Identity_name)
                          type: 'ManagedServiceIdentity'
                        }
                        body: {
                          text: '**Device name:** @{items(\'For_each_deploymentState\')?[\'managedDeviceName\']}\n\n **Device serial nr:** @{items(\'For_each_deploymentState\')?[\'deviceSerialNumber\']}\n\n **OS Version:** @{items(\'For_each_deploymentState\')?[\'osVersion\']}\n\n **Manufacturer:** @{items(\'For_each_windowsAutopilotDeviceIdentities\')?[\'manufacturer\']}\n\n **Model:** @{items(\'For_each_windowsAutopilotDeviceIdentities\')?[\'model\']}\n\n **User:** \n\n **Autopilot Deployment profile:** @{items(\'For_each_deploymentState\')?[\'windowsAutopilotDeploymentProfileDisplayName\']}\n\n **Targeted App Count:** @{items(\'For_each_deploymentState\')?[\'targetedAppCount\']}\n\n **Targeted Policy Count:** @{items(\'For_each_deploymentState\')?[\'targetedPolicyCount\']}\n\n **Deployment Status:** @{items(\'For_each_deploymentState\')?[\'deploymentState\']}\n\n **Deployment start time:** @{items(\'For_each_deploymentState\')?[\'deploymentStartDateTime\']}\n\n **Deployment end time:** @{items(\'For_each_deploymentState\')?[\'deploymentEndDateTime\']}\n\n **Deployment duration:** @{items(\'For_each_deploymentState\')?[\'deploymentDuration\']}'
                          title: 'Windows Autopilot deployment finished for @{items(\'For_each_deploymentState\')?[\'managedDeviceName\']} with status @{items(\'For_each_deploymentState\')?[\'deploymentState\']}'
                        }
                        headers: {
                          'Content-Type': 'application/json'
                        }
                        method: 'POST'
                        uri: ''
                      }
                    }
                  }
                  runAfter: {
                    Parse_JSON_GET_windowsAutopilotDeviceIdentities: [
                      'Succeeded'
                    ]
                  }
                  type: 'Foreach'
                }
                HTTP_GET_windowsAutopilotDeviceIdentities: {
                  runAfter: {}
                  type: 'Http'
                  inputs: {
                    authentication: {
                      audience: 'https://graph.microsoft.com/'
                      identity: resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedIdentities_WAD_Identity_name)
                      type: 'ManagedServiceIdentity'
                    }
                    method: 'GET'
                    uri: 'https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities?$filter=((contains(serialnumber,\'@{items(\'For_each_deploymentState\')?[\'deviceSerialNumber\']}\')))'
                  }
                }
                Parse_JSON_GET_windowsAutopilotDeviceIdentities: {
                  runAfter: {
                    HTTP_GET_windowsAutopilotDeviceIdentities: [
                      'Succeeded'
                    ]
                  }
                  type: 'ParseJson'
                  inputs: {
                    content: '@body(\'HTTP_GET_windowsAutopilotDeviceIdentities\')'
                    schema: {
                      properties: {
                        '@@odata.context': {
                          type: 'string'
                        }
                        '@@odata.count': {
                          type: 'integer'
                        }
                        value: {
                          items: {
                            properties: {
                              addressableUserName: {
                                type: 'string'
                              }
                              azureActiveDirectoryDeviceId: {
                                type: 'string'
                              }
                              azureAdDeviceId: {
                                type: 'string'
                              }
                              deploymentProfileAssignedDateTime: {
                                type: 'string'
                              }
                              deploymentProfileAssignmentDetailedStatus: {
                                type: 'string'
                              }
                              deploymentProfileAssignmentStatus: {
                                type: 'string'
                              }
                              displayName: {
                                type: 'string'
                              }
                              enrollmentState: {
                                type: 'string'
                              }
                              groupTag: {
                                type: 'string'
                              }
                              id: {
                                type: 'string'
                              }
                              lastContactedDateTime: {
                                type: 'string'
                              }
                              managedDeviceId: {
                                type: 'string'
                              }
                              manufacturer: {
                                type: 'string'
                              }
                              model: {
                                type: 'string'
                              }
                              productKey: {
                                type: 'string'
                              }
                              purchaseOrderIdentifier: {
                                type: 'string'
                              }
                              resourceName: {
                                type: 'string'
                              }
                              serialNumber: {
                                type: 'string'
                              }
                              skuNumber: {
                                type: 'string'
                              }
                              systemFamily: {
                                type: 'string'
                              }
                              userPrincipalName: {
                                type: 'string'
                              }
                            }
                            required: [
                              'id'
                              'deploymentProfileAssignmentStatus'
                              'deploymentProfileAssignmentDetailedStatus'
                              'deploymentProfileAssignedDateTime'
                              'groupTag'
                              'purchaseOrderIdentifier'
                              'serialNumber'
                              'productKey'
                              'manufacturer'
                              'model'
                              'enrollmentState'
                              'lastContactedDateTime'
                              'addressableUserName'
                              'userPrincipalName'
                              'resourceName'
                              'skuNumber'
                              'systemFamily'
                              'azureActiveDirectoryDeviceId'
                              'azureAdDeviceId'
                              'managedDeviceId'
                              'displayName'
                            ]
                            type: 'object'
                          }
                          type: 'array'
                        }
                      }
                      type: 'object'
                    }
                  }
                }
              }
              runAfter: {}
              expression: {
                and: [
                  {
                    not: {
                      equals: [
                        ''
                        'inProgress'
                      ]
                    }
                  }
                ]
              }
              type: 'If'
            }
          }
          runAfter: {
            Parse_JSON_GET_autopilotEvents: [
              'Succeeded'
            ]
          }
          type: 'Foreach'
        }
        HTTP_GET_autopilotEvents: {
          runAfter: {}
          type: 'Http'
          inputs: {
            authentication: {
              audience: 'https://graph.microsoft.com/'
              identity: resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', userAssignedIdentities_WAD_Identity_name)
              type: 'ManagedServiceIdentity'
            }
            method: 'GET'
            uri: 'https://graph.microsoft.com/beta/deviceManagement/autopilotEvents?$filter=microsoft.graph.DeviceManagementAutopilotEvent/deploymentEndDateTime%20ge%20@{addhours(utcNow(\'yyyy-MM-ddTHH:mm:ssZ\'),-1)}'
          }
        }
        Parse_JSON_GET_autopilotEvents: {
          runAfter: {
            HTTP_GET_autopilotEvents: [
              'Succeeded'
            ]
          }
          type: 'ParseJson'
          inputs: {
            content: '@body(\'HTTP_GET_autopilotEvents\')'
            schema: {
              properties: {
                '@@odata.context': {
                  type: 'string'
                }
                value: {
                  items: {
                    properties: {
                      accountSetupDuration: {
                        type: 'string'
                      }
                      accountSetupStatus: {
                        type: 'string'
                      }
                      deploymentDuration: {
                        type: 'string'
                      }
                      deploymentEndDateTime: {
                        type: 'string'
                      }
                      deploymentStartDateTime: {
                        type: 'string'
                      }
                      deploymentState: {
                        type: 'string'
                      }
                      deploymentTotalDuration: {
                        type: 'string'
                      }
                      deviceId: {
                        type: 'string'
                      }
                      devicePreparationDuration: {
                        type: 'string'
                      }
                      deviceRegisteredDateTime: {
                        type: 'string'
                      }
                      deviceSerialNumber: {
                        type: 'string'
                      }
                      deviceSetupDuration: {
                        type: 'string'
                      }
                      deviceSetupStatus: {
                        type: 'string'
                      }
                      enrollmentFailureDetails: {}
                      enrollmentStartDateTime: {
                        type: 'string'
                      }
                      enrollmentState: {
                        type: 'string'
                      }
                      enrollmentType: {
                        type: 'string'
                      }
                      eventDateTime: {
                        type: 'string'
                      }
                      id: {
                        type: 'string'
                      }
                      managedDeviceName: {
                        type: 'string'
                      }
                      osVersion: {
                        type: 'string'
                      }
                      targetedAppCount: {
                        type: 'integer'
                      }
                      targetedPolicyCount: {
                        type: 'integer'
                      }
                      userPrincipalName: {
                        type: 'string'
                      }
                      windows10EnrollmentCompletionPageConfigurationDisplayName: {
                        type: [
                          'string'
                          'null'
                        ]
                      }
                      windows10EnrollmentCompletionPageConfigurationId: {}
                      windowsAutopilotDeploymentProfileDisplayName: {
                        type: [
                          'string'
                          'null'
                        ]
                      }
                    }
                    required: [
                      'id'
                      'deviceId'
                      'eventDateTime'
                      'deviceRegisteredDateTime'
                      'enrollmentStartDateTime'
                      'enrollmentType'
                      'deviceSerialNumber'
                      'managedDeviceName'
                      'userPrincipalName'
                      'windowsAutopilotDeploymentProfileDisplayName'
                      'enrollmentState'
                      'windows10EnrollmentCompletionPageConfigurationDisplayName'
                      'windows10EnrollmentCompletionPageConfigurationId'
                      'deploymentState'
                      'deviceSetupStatus'
                      'accountSetupStatus'
                      'osVersion'
                      'deploymentDuration'
                      'deploymentTotalDuration'
                      'devicePreparationDuration'
                      'deviceSetupDuration'
                      'accountSetupDuration'
                      'deploymentStartDateTime'
                      'deploymentEndDateTime'
                      'targetedAppCount'
                      'targetedPolicyCount'
                      'enrollmentFailureDetails'
                    ]
                    type: 'object'
                  }
                  type: 'array'
                }
              }
              type: 'object'
            }
          }
        }
      }
      outputs: {}
    }
    parameters: {}
  }
}
