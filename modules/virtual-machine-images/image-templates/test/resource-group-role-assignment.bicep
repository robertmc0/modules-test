@description('Role assignment name. Must be a globally unique identifier (GUID).')
param roleAssignmentName string

@description('The role definition ID.')
param roleDefinitionId string

@description('The principal ID.')
param principalId string

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: roleAssignmentName
  properties: {
    roleDefinitionId: roleDefinitionId
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
