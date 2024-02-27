/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('The storage account resource name.')
param storageName string = 'sa${uniqueString(deployment().name, location)}'

@description('The log analytics resource name.')
param logAnalyticsName string = 'law-${uniqueString(deployment().name, location)}'

/*======================================================================
TEST PREREQUISITES
======================================================================*/

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {//name needs to be addressed
  name: storageName
  location: location
  kind: 'BlobStorage'
  properties: {
    accessTier: 'Hot'
  }
  sku: {
    name: 'Standard_GRS'
  }
}

resource diagnosticsStorageAccountPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = {
  parent: storage
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

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/

module searchService '../main.bicep' = {
  name: 'searchService-${uniqueString(deployment().name, location)}'
  params: {
    name: 'moduletst-${uniqueString(deployment().name, location)}'
    tags: tags
    location: location
  }
}

module searchServiceSemantic '../main.bicep' = {
  name: 'searchServiceSem-${uniqueString(deployment().name, location)}'
  params: {
    name: 'moduletstsem-${uniqueString(deployment().name, location)}'
    tags: tags
    location: location
    semanticSearch: 'free'
    sku: 'standard'
  }
}

module searchServiceLck '../main.bicep' = {
  name: 'searchServiceLck-${uniqueString(deployment().name, location)}'
  params: {
    name: 'moduletstlck-${uniqueString(deployment().name, location)}'
    tags: tags
    location: location
    resourcelock: 'CanNotDelete'
  }
}

module searchServiceDiags '../main.bicep' = {
  name: 'searchServiceDiags-${uniqueString(deployment().name, location)}'
  params: {
    name: 'moduletstdiags-${uniqueString(deployment().name, location)}'
    tags: tags
    location: location
    enableDiagnostics: true
    diagnosticStorageAccountId: storage.id
    diagnosticLogAnalyticsWorkspaceId: logAnalytics.id
  }
}
