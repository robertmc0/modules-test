metadata name = 'Static Web App'
metadata description = 'This module deploys a Static Web App (Microsoft.Web/staticSites)'
metadata owner = 'Arinco'

@description('The geo-location where the resource lives.')
param location string

@description('Name of Static Web App.')
param name string

@allowed([
  'Free'
  'Standard'
])
@description('Optional. Name of the  Static Web App SKU.')
param sku string = 'Free'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${name}-${resourceLock}-lck')

resource staticWebApp 'Microsoft.Web/staticSites@2024-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {}
  sku: {
    name: sku
    tier: sku
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: staticWebApp
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}

// Outputs
@description('The name of the deployed resource.')
output name string = staticWebApp.name

@description('The resource ID of the deployed resource.')
output resourceId string = staticWebApp.id
