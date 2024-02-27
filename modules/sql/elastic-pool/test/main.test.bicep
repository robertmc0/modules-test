/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('Optional. The resource deployment name.')
param deploymentName string = 'elasticPool${utcNow()}'

@description('Optional. Resource tags.')
param tags object = {}

@secure()
@description('SQL administrator login password')
param sqlAdminPassword string = '${toUpper(uniqueString(resourceGroup().id))}-${newGuid()}'

/*======================================================================
TEST PREREQUISITES
======================================================================*/

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deploymentName, 'diagnosticsStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
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

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deploymentName, 'logAnalyticsWorkspace', location)}'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: '${shortIdentifier}-tst-sql-${uniqueString(deploymentName, 'sqlserver', location)}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    version: '12.0'
    publicNetworkAccess: 'Enabled'
    minimalTlsVersion: '1.2'
    administratorLogin: '${shortIdentifier}sqladmin'
    administratorLoginPassword: sqlAdminPassword
  }
}

module elasticPoolMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-elastic-pool'
  params: {
    location: location
    sqlServerName: sqlServer.name
    name: 'example-min-elastic-pool'
    skuType: 'StandardPool'
    skuCapacity: 50
    maxPoolSize: 53687091200 // 50 GIG
  }
}

module elasticPool '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-elastic-pool'
  params: {
    location: location
    sqlServerName: sqlServer.name
    name: 'example-elastic-pool'
    skuType: 'StandardPool'
    skuCapacity: 50
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
    maxPoolSize: 53687091200 // 50 GIG
  }
}
