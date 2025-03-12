@description('Optional. The location to deploy resources to')
param location string = 'australiaeast'

var uniqueName = uniqueString(deployment().name, location)

@secure()
param psqlPassword string = uniqueString(newGuid())

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${uniqueName}-law'
  location: location
}
resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${uniqueName}sa'
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

module postgresmin '../main.bicep' = {
  name: 'deploy_postgres-min'
  params: {
    location: location
    name: '${uniqueName}-postgres-min'
    administratorLogin: 'psqladmin'
    administratorLoginPassword: psqlPassword
    backupRetentionDays: 30
    skuName: 'Standard_D2ds_v4'
    skuTier: 'GeneralPurpose'
    storageSizeGB: 64
    version: '13'
  }
}

module postgres '../main.bicep' = {
  name: 'deploy_postgres'
  params: {
    location: location
    name: '${uniqueName}-postgres'
    administratorLogin: 'psqladmin'
    administratorLoginPassword: psqlPassword
    backupRetentionDays: 30
    skuName: 'Standard_D2ds_v4'
    skuTier: 'GeneralPurpose'
    storageSizeGB: 64
    version: '13'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
    diagnosticStorageAccountId: diagnosticsStorageAccount.id
  }
}
