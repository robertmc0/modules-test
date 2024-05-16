metadata name = 'TODO: <module name>'
metadata description = 'TODO: <module description>'
metadata owner = 'TODO: <GitHub username of module owner>'

targetScope = 'managementGroup'

@sys.description('Specifies the name of the policy assignment. Maximum length is 24 characters for management group scope.')
@minLength(1)
@maxLength(24)
param name string

@sys.description('Optional. The location of the policy assignment. Only required when utilizing managed identity.')
param location string = deployment().location

@sys.description('The display name of the policy assignment. Maximum length is 128 characters.')
@maxLength(128)
param displayName string

@sys.description('This message will be part of response in case of policy violation.')
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
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments?pivots=deployment-language-bicep#identity'
  example: {
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        userAssignedManagedIdentity: {}
      }
    }
  }
})
param userAssignedIdentities object = {}

@sys.description('Optional. The message that describe why a resource is non-compliant with the policy.')
param nonComplianceMessage string = ''

@sys.description('Optional. The policy excluded scopes.')
param notScopes array = []

@sys.description('Optional. The parameter values for the assigned policy rule. The keys are the parameter names.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments?pivots=deployment-language-bicep#policyassignmentproperties'
  example: {
    parameters: {
      listOfAllowedLocations: {
        type: 'Array'
        metadata: {
          description: 'The list of locations that can be specified when deploying resources.'
          strongType: 'location'
          displayName: 'Allowed locations'
        }
        defaultValue: [ 'australiaeast', 'australiasoutheast' ]
      }
    }
  }
})
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
    notScopes: notScopes
    parameters: parameters
    policyDefinitionId: policyDefinitionId
  }
}

resource policyRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (identityType == 'SystemAssigned') {
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

@sys.description('The principal ID of the system assigned identity.')
output systemAssignedPrincipalId string = systemAssignedIdentity && contains(policyAssignment.identity, 'principalId') ? policyAssignment.identity.principalId : ''
