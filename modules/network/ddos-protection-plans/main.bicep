@description('The resource name.')
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourcelock string = 'NotSpecified'

var lockName = toLower('${ddosProtectionPlan.name}-${resourcelock}-lck')

resource ddosProtectionPlan 'Microsoft.Network/ddosProtectionPlans@2021-08-01' = {
  name: name
  location: location
  tags: tags
  properties: {}
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: ddosProtectionPlan
  name: lockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed ddos protection plan.')
output name string = ddosProtectionPlan.name

@description('The resource ID of the deployed ddos protection plan.')
output resourceId string = ddosProtectionPlan.id
