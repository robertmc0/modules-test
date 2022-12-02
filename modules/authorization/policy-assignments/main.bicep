targetScope = 'managementGroup'

@sys.description('Required. Specifies the name of the policy assignment. Maximum length is 24 characters for management group scope.')
@minLength(1)
@maxLength(24)
param name string

@sys.description('Optional. The location of the policy assignment. Only required when utilizing managed identity.')
param location string = deployment().location

@sys.description('Required. The display name of the policy assignment. Maximum length is 128 characters.')
@maxLength(128)
param displayName string

@sys.description('Required. This message will be part of response in case of policy violation.')
param description string

@sys.description('Optional. The policy assignment enforcement mode.')
@allowed([
  'Default'
  'DoNotEnforce'
])
param enforcementMode string = 'Default'

@sys.description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@sys.description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@sys.description('Optional. The message that describe why a resource is non-compliant with the policy.')
param nonComplianceMessage string = ''

@sys.description('Optional. The policy excluded scopes.')
param notScopes array = []

@sys.description('Optional. The parameter values for the assigned policy rule. The keys are the parameter names.')
param parameters object = {}

@sys.description('The ID of the policy definition or policy set definition being assigned.')
param policyDefinitionId string

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: name
  location: location
  identity: identity
  properties: {
    description: description
    displayName: displayName
    enforcementMode: enforcementMode
    nonComplianceMessages: !empty(nonComplianceMessage) ? [
      {
        message: nonComplianceMessage
      }
    ] : null
    notScopes: !empty(notScopes) ? notScopes : []
    parameters: parameters
    policyDefinitionId: policyDefinitionId
  }
}

resource policyRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(identity)) {
  name: guid(policyAssignment.name, policyAssignment.type, policyAssignment.id)
  properties: {
    principalId: policyAssignment.identity.principalId
    roleDefinitionId: tenantResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor role required for policy with deployIfNotExists/modify effects
    principalType: 'ServicePrincipal'
  }
}

@sys.description('The name of the policy assignment.')
output name string = policyAssignment.name

@sys.description('The resource ID of the policy assignment.')
output resourceId string = policyAssignment.id
