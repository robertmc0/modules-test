targetScope = 'subscription'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. The geo-location where the resource lives.')
param location string = deployment().location

@description('Resource group name to support registry.')
param resourceGroupName string

@description('Container registry name.')
param containerRegistryName string

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

module containerRegistry '../../modules/container-registry/registries/main.bicep' = {
  scope: rg
  name: 'containerRegistryModule'
  params: {
    location: location
    name: containerRegistryName
    tags: tags
    resourceLock: 'CanNotDelete'
    sku: 'Standard'
  }
}
