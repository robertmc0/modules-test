@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'mls'

@description('The storage account resource name.')
param storageName string = '${shortIdentifier}tst${uniqueString(deployment().name, 'storageAccount', location)}'

@description('Name of ApplicationInsights.')
param applicationInsightsName string = '${shortIdentifier}-tst-ai-${uniqueString(deployment().name, 'ai', location)}'

@description('The geo-location where the resource lives.')
param location string

@description('The container registry bind to the workspace.')
param containerRegistryName string = '${shortIdentifier}tst${uniqueString(deployment().name, 'cr', location)}'

@description('Name of the key vault.')
param keyVaultName string = '${shortIdentifier}-tst-kv-${uniqueString(deployment().name, 'kv', location)}'

var tenantId = subscription().tenantId

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: []
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Basic'
  }
}

resource insights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

@description('The name of the deployed Storage Account.')
output storageName string = storage.name

@description('The resource ID of the deployed Storage Account.')
output storageAccountResourceId string = storage.id

@description('The name of the deployed Key Vault.')
output keyVaultName string = keyVault.name

@description('The resource ID of the deployed Key Vault.')
output keyVaultResourceId string = keyVault.id

@description('The name of the deployed Container Registry.')
output containerRegistryName string = containerRegistry.name

@description('The resource ID of the deployed Container Registry.')
output containerRegistryResourceId string = containerRegistry.id

@description('The name of the deployed Application Insights.')
output applicationInsightsName string = insights.name

@description('The resource ID of the deployed Application Insights.')
output applicationInsightsResourceId string = insights.id
