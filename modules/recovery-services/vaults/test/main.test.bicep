/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('Optional. Admin username for virtual machine.')
param adminUser string = 'azureuser'

@description('Optional. Admin password for virtual machine.')
@secure()
param adminPassword string = '${toUpper(uniqueString(resourceGroup().id))}-${newGuid()}'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-01-01' = {
  name: '${shortIdentifier}tstvm${uniqueString(deployment().name, 'virtualMachines', location)}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/default'
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: '${shortIdentifier}tstvm${uniqueString(deployment().name, 'virtualMachines', location)}'
  location: location
  properties: {
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: '${shortIdentifier}tstvm${uniqueString(deployment().name, 'virtualMachines', location)}'
      adminUsername: adminUser
      adminPassword: adminPassword
    }
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    storageProfile: {
      imageReference: {
        publisher: 'canonical'
        offer: '0001-com-ubuntu-server-focal'
        sku: '20_04-lts'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
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
module vaultMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-vault'
  params: {
    name: '${uniqueString(deployment().name, location)}-min-vault'
    location: location
  }
}

module vault '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vault'
  params: {
    name: '${uniqueString(deployment().name, location)}-vault'
    location: location
    storageType: 'GeoRedundant'
    enablecrossRegionRestore: true
    backupPolicies: [
      {
        name: 'Policy-Example1'
        properties: {
          backupManagementType: 'AzureIaasVM'
          instantRPDetails: {
            azureBackupRGNamePrefix: '${shortIdentifier}-ae-backup-'
            azureBackupRGNameSuffix: '00'
          }
          instantRpRetentionRangeInDays: 2
          schedulePolicy: {
            scheduleRunFrequency: 'Daily'
            scheduleRunTimes: [
              '2022-09-01T21:00:00Z'
            ]
            schedulePolicyType: 'SimpleSchedulePolicy'
          }
          timeZone: 'AUS Eastern Standard Time'
          retentionPolicy: {
            dailySchedule: {
              retentionTimes: [
                '2022-09-01T21:00:00Z'
              ]
              retentionDuration: {
                count: 14
                durationType: 'Days'
              }
            }
            retentionPolicyType: 'LongTermRetentionPolicy'
          }
        }
      }
      {
        name: 'Policy-Example2'
        properties: {
          backupManagementType: 'AzureIaasVM'
          instantRpRetentionRangeInDays: 5
          schedulePolicy: {
            scheduleRunFrequency: 'Weekly'
            scheduleRunDays: [
              'Sunday'
              'Wednesday'
            ]
            scheduleRunTimes: [
              '2022-09-01T21:00:00Z'
            ]
            schedulePolicyType: 'SimpleSchedulePolicy'
          }
          timeZone: 'AUS Eastern Standard Time'
          retentionPolicy: {
            dailySchedule: null
            weeklySchedule: {
              daysOfTheWeek: [
                'Sunday'
                'Wednesday'
              ]
              retentionTimes: [
                '2022-09-01T21:00:00Z'
              ]
              retentionDuration: {
                count: 4
                durationType: 'Weeks'
              }
            }
            monthlySchedule: {
              retentionScheduleFormatType: 'Weekly'
              retentionScheduleDaily: {
                daysOfTheMonth: [
                  {
                    date: 1
                    isLast: false
                  }
                ]
              }
              retentionScheduleWeekly: {
                daysOfTheWeek: [
                  'Sunday'
                  'Wednesday'
                ]
                weeksOfTheMonth: [
                  'First'
                  'Third'
                ]
              }
              retentionTimes: [
                '2022-09-01T21:00:00Z'
              ]
              retentionDuration: {
                count: 12
                durationType: 'Months'
              }
            }
            yearlySchedule: {
              retentionScheduleFormatType: 'Weekly'
              monthsOfYear: [
                'January'
                'March'
                'August'
              ]
              retentionScheduleDaily: {
                daysOfTheMonth: [
                  {
                    date: 1
                    isLast: false
                  }
                ]
              }
              retentionScheduleWeekly: {
                daysOfTheWeek: [
                  'Sunday'
                  'Wednesday'
                ]
                weeksOfTheMonth: [
                  'First'
                  'Third'
                ]
              }
              retentionTimes: [
                '2022-09-01T21:00:00Z'
              ]
              retentionDuration: {
                count: 7
                durationType: 'Years'
              }
            }
            retentionPolicyType: 'LongTermRetentionPolicy'
          }
        }
      }
    ]
    addVmToBackupPolicy: [
      {
        resourceId: virtualMachine.id
        backupPolicyName: 'Policy-Example1'

      }
    ]
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    diagnosticEventHubAuthorizationRuleId: '${diagnosticsEventHubNamespace.id}/authorizationrules/RootManageSharedAccessKey'
    resourceLock: 'CanNotDelete'
  }
}
