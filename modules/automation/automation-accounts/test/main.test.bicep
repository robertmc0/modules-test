/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('Optional. Get UTC for basetime calculations in code.')
param baseTime string = utcNow('u')

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${shortIdentifier}-tst-umi-${uniqueString(deployment().name, 'umi', location)}'
  location: location
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
module automationAccountMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-auto'
  params: {
    name: '${shortIdentifier}-tst-auto-min-${uniqueString(deployment().name, 'automationAccount', location)}'
    location: location
  }
}

module automationAccount '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-auto'
  params: {
    name: '${shortIdentifier}-tst-auto-${uniqueString(deployment().name, 'automationAccount', location)}'
    location: location
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
    modules: [
      {
        name: 'Az.Accounts'
        version: 'latest'
        uri: 'https://www.powershellgallery.com/api/v2/package'
      }
    ]
    runbooks: [
      {
        runbookName: 'AzureAutomationTutorialImported'
        runbookUri: 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.automation/101-automation/scripts/AzureAutomationTutorial.ps1'
        runbookType: 'PowerShell'
        logProgress: true
        logVerbose: false
        linkSchedule: 'auto-shutdown-1'
      }
      {
        runbookName: 'AzureAutomationTutorialImportedTest'
        runbookUri: 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/quickstarts/microsoft.automation/101-automation/scripts/AzureAutomationTutorial.ps1'
        runbookType: 'PowerShell'
        logProgress: true
        logVerbose: false
      }
    ]
    schedules: [
      {
        name: 'auto-shutdown-1'
        description: 'Auto shutdown'
        startTime: dateTimeAdd(baseTime, 'PT3H', 'yyyy-MM-ddTHH:mm+00:00')
        frequency: 'Hour'
        interval: 1
        timeZone: 'AUS Eastern Standard Time'
      }
    ]
    variables: [
      {
        name: 'userAssignedIdentity'
        description: 'User Assigned Identity Name'
        isEncrypted: false
        value: '"3802097b-a159-4529-84b3-0004bfa45958"'
      }
      {
        name: 'workspaceId'
        description: 'Log Analytics Workspace ID to query'
        isEncrypted: false
        value: '"0e246377-00a7-4038-afb5-ec3551e3f9e5"'
      }
      {
        name: 'vmprefix'
        description: 'AVD name prefix.'
        isEncrypted: false
        value: '"avdn"'
      }
    ]
    updateScheduleConfig: [
      {
        name: 'windows-updates'
        scheduleInfo: {
          startTime: dateTimeAdd(baseTime, 'P1D', 'yyyy-MM-ddTHH:mm+00:00')
          frequency: 'Month'
          timeZone: 'AUS Eastern Standard Time'
          interval: 1
        }
        updateConfiguration: {
          operatingSystem: 'Windows'
          duration: 'PT5H'
          targets: {
            azureQueries: [
              {
                locations: [
                  'australiaeast'
                  'australiasoutheast'
                ]
                scope: [
                  'subscriptions/${subscription().subscriptionId}'
                ]
              }
            ]
          }
          windows: {
            includedUpdateClassifications: 'Critical, Security'
          }
        }
      }
      {
        name: 'linux-updates'
        scheduleInfo: {
          startTime: dateTimeAdd(baseTime, 'P1D', 'yyyy-MM-ddTHH:mm+00:00')
          frequency: 'Week'
          timeZone: 'AUS Eastern Standard Time'
          interval: 4
        }
        updateConfiguration: {
          operatingSystem: 'Linux'
          duration: 'PT5H'
          targets: {
            azureQueries: [
              {
                locations: [
                  'australiaeast'
                  'australiasoutheast'
                ]
                scope: [
                  'subscriptions/${subscription().subscriptionId}'
                ]
              }
            ]
          }
          linux: {
            includedPackageClassifications: 'Critical, Security'
          }
        }
      }
    ]
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
