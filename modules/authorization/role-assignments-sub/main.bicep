targetScope = 'subscription'

@description('Optional. The resource name. Must be a globally unique identifier (GUID).')
@minLength(1)
@maxLength(36)
param name string = guid(subscription().subscriptionId, roleDefinitionId, principalId)

@description('The role definition ID.')
param roleDefinitionId string

@description('The principal type of the assigned principal ID.')
@allowed([
  'Group'
  'ServicePrincipal'
  'User'
  'Device'
  'ForeignGroup'
])
param principalType string

@description('The principal ID.')
param principalId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: name
  properties: {
    roleDefinitionId: roleDefinitionId
    principalType: principalType
    principalId: principalId
  }
}

@description('The name of the deployed role assignment.')
output name string = roleAssignment.name

@description('The resource ID of the deployed role assignment.')
output resourceId string = roleAssignment.id
