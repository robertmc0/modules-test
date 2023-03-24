targetScope = 'subscription'

// @description('Prefix value which will be prepended to all resource names.')
// @minLength(2)
// @maxLength(4)
// param companyPrefix string

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

@description('Optional. Bootstrap resource group name.')
param resourceGroupName string //= '${companyPrefix}-${locationIdentifier}-bootstrap-rg'

@description('Optional. Container registry name.')
param containerRegistryName string // = '${companyPrefix}${locationIdentifier}bicepmodulesacr'

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
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
