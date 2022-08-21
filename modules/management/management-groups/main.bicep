targetScope = 'tenant'

@description('The resource name. This is also referred to as the management group ID.')
param name string

@description('The friendly name of the management group.')
param displayName string

@description('Optional. The ID of the parent management group.')
param parent string = ''

resource managementGroup 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: name
  properties: {
    displayName: displayName
    details: {
      parent: !empty(parent) ? {
        id: parent
      } : null
    }
  }
}

@description('The name of the deployed management group.')
output name string = managementGroup.name

@description('The resource ID of the deployed management group.')
output resourceId string = managementGroup.id
