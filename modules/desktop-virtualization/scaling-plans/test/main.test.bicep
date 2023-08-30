/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {
  environment: 'test'
}

/*======================================================================
TEST PREREQUISITES
======================================================================*/
// Note: In order to deploy scaling plans you must assign the Desktop Virtualization Power On Off Contributor role to the Azure Virtual Desktop service principal. Reference article https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-scaling-plan#assign-the-desktop-virtualization-power-on-off-contributor-role-with-the-azure-portal.

resource hostPool1 'Microsoft.DesktopVirtualization/hostPools@2022-04-01-preview' = {
  name: '${shortIdentifier}-tst-hp-${uniqueString(deployment().name, 'hostPool1', location)}'
  location: location
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
  }
}

resource hostPool2 'Microsoft.DesktopVirtualization/hostPools@2022-04-01-preview' = {
  name: '${shortIdentifier}-tst-hp-${uniqueString(deployment().name, 'hostPool2', location)}'
  location: location
  properties: {
    hostPoolType: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    preferredAppGroupType: 'Desktop'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource diagnosticsStorageAccountPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = {
  parent: diagnosticsStorageAccount
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          name: 'blob-lifecycle'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                tierToCool: {
                  daysAfterModificationGreaterThan: 30
                }
                delete: {
                  daysAfterModificationGreaterThan: 365
                }
              }
              snapshot: {
                delete: {
                  daysAfterCreationGreaterThan: 365
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
          }
        }
      ]
    }
  }
}

resource diagnosticsEventHubNamespace 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsEventHubNamespace', location)}'
  location: location
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module minScalingPlan '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-scale'
  params: {
    name: '${shortIdentifier}-tst-min-${uniqueString(deployment().name, 'scalingPlan', location)}'
    location: location
    hostPoolReferences: [
      hostPool1.id
    ]
    schedules: []
    timeZone: 'AUS Eastern Standard Time'
  }
}

module scalingPlan '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-scale'
  params: {
    name: '${shortIdentifier}-tst-${uniqueString(deployment().name, 'scalingPlan', location)}'
    location: location
    tags: tags
    friendlyName: 'scaling plan for testing'
    scalingPlanDescription: 'scaling plan used for testing purposes'
    exclusionTag: 'prod'
    hostPoolReferences: [
      hostPool2.id
    ]
    schedules: [
      {
        name: 'schedule1'
        daysOfWeek: [
          'Monday'
          'Wednesday'
        ]
        rampUpStartTime: {
          hour: 7
          minute: 0
        }
        rampUpLoadBalancingAlgorithm: 'BreadthFirst'
        rampUpMinimumHostsPct: 75
        rampUpCapacityThresholdPct: 60
        peakStartTime: {
          hour: 8
          minute: 0
        }
        peakLoadBalancingAlgorithm: 'BreadthFirst'
        rampDownStartTime: {
          hour: 21
          minute: 0
        }
        rampDownLoadBalancingAlgorithm: 'DepthFirst'
        rampDownMinimumHostsPct: 5
        rampDownCapacityThresholdPct: 60
        rampDownWaitTimeMinutes: 30
        rampDownStopHostsWhen: 'ZeroSessions'
        rampDownNotificationMessage: 'You will be logged off in 30 minutes. Please ensure you save your work.'

        offPeakStartTime: {
          hour: 21
          minute: 30
        }
        offPeakLoadBalancingAlgorithm: 'DepthFirst'
        rampDownForceLogoffUsers: true
      }

    ]
    timeZone: 'AUS Eastern Standard Time'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
