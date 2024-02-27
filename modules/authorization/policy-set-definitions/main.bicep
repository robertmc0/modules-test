targetScope = 'managementGroup'

@sys.description('Specifies the name of the policy Set Definition (Initiative).')
@maxLength(64)
param name string

@sys.description('The description name of the Set Definition (Initiative).')
param description string

@sys.description('The display name of the Set Definition (Initiative). Maximum length is 128 characters.')
@maxLength(128)
param displayName string

@sys.description('Optional. The policy set definition parameters that can be used in policy definition references.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions?pivots=deployment-language-bicep#policysetdefinitionproperties'
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

@sys.description('Optional. The Set Definition (Initiative) metadata. Metadata is an open ended object and is typically a collection of key-value pairs.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions?pivots=deployment-language-bicep#policysetdefinitionproperties'
  example: {
    metadata: {
      version: '1.0.0'
    }
  }
})
param polMetadata object = {}

@sys.description('The array of Policy definitions object to include for this policy set. Each object must include the Policy definition ID, and optionally other properties like parameters.')
param policyDefinitions array

@sys.description('Optional. The metadata describing groups of policy definition references within the Policy Set Definition (Initiative).')
param policyDefinitionGroups array = []

resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: name
  properties: {
    policyType: 'Custom'
    displayName: displayName
    description: description
    metadata: !empty(polMetadata) ? polMetadata : null
    parameters: parameters
    policyDefinitions: policyDefinitions
    policyDefinitionGroups: !empty(policyDefinitionGroups) ? policyDefinitionGroups : []
  }
}

@sys.description('The name of the deployed policy set definition.')
output name string = policySetDefinition.name

@sys.description('The resource ID of the deployed policy set definition.')
output resourceId string = policySetDefinition.id
