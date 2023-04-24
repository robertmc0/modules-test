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

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = true

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'CanNotDelete'

var lockName = toLower('${adbAccessConnector.name}-${resourceLock}-lck')

resource adbAccessConnector 'Microsoft.Databricks/accessConnectors@2022-04-01-preview' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: systemAssignedIdentity ? 'SystemAssigned' : 'None'
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: adbAccessConnector
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed access connector.')
output name string = adbAccessConnector.name

@description('The resource ID of the deployed access connector.')
output resourceId string = adbAccessConnector.id

@description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(adbAccessConnector.identity, 'principalId') ? adbAccessConnector.identity.principalId : ''
