targetScope = 'managementGroup'

@sys.description('The resource name.')
param name string

@sys.description('The policy set definition description.')
param description string

@sys.description('The display name of the policy set definition.')
param displayName string

@sys.description('Optional. The policy set definition parameters that can be used in policy definition references.')
param parameters object = {}

@sys.description('Policy definition references.')
@metadata({
  groupNames: 'The name of the groups that this policy definition reference belongs to.'
  parameters: 'The parameter values for the referenced policy rule. The keys are the parameter names.'
  policyDefinitionId: 'The ID of the policy definition or policy set definition.'
  policyDefinitionReferenceId: 'A unique id (within the policy set definition) for this policy definition reference.'
})
param policyDefinitions array

resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: name
  properties: {
    description: description
    displayName: displayName
    parameters: parameters
    policyDefinitions: [for policy in policyDefinitions: {
      policyDefinitionId: policy.policyDefinitionId
      parameters: policy.parameters
    }]
    policyType: 'Custom'
  }
}

@sys.description('The name of the deployed policy set definition.')
output name string = policySetDefinition.name

@sys.description('The resource ID of the deployed policy set definition.')
output resourceId string = policySetDefinition.id
