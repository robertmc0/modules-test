metadata name = 'Azure Cognitive Service'
metadata description = 'Deploys Azure Cognitive Service Account, including deployments as required.'
metadata owner = 'Arinco'

@description('The name of the Cognitive Service Account.')
param name string

@description('The kind Cognitive Service resource being created.')
@allowed([
  'CognitiveServices'
  'TextTranslation'
  'ComputerVision'
  'OpenAI'
])
param kind string = 'OpenAI'

@description('The SKU used for your Cognitive Service.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/2023-05-01/accounts?pivots=deployment-language-bicep#sku'
  example: {
    name: 'S0'
  }
})
@allowed([
  'F0'
  'S0'
  'S1'
  'S2'
  'S3'
  'S4'
])
param sku string = 'S0'

@description('Optional. The location of the Cognitive Service Account.')
param location string = resourceGroup().location

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. The publicly visible subdomain for your Cognitive Service.')
param customSubDomainName string = name

@description('Optional. Deployments for use when creating OpenAI Resources.')
param deployments array = []

@description('Optional. Whether or not public endpoint access is allowed for this account.')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Optional. The properties to be used for each individual cognitive service.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.cognitiveservices/2023-05-01/accounts?pivots=deployment-language-bicep#accountproperties'
})
param properties object = {
  customSubDomainName: customSubDomainName
  publicNetworkAccess: publicNetworkAccess
}

resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  tags: tags
  kind: kind
  properties: properties
  sku: {
    name: sku
  }
}

@batchSize(1)
resource deployment 'Microsoft.CognitiveServices/accounts/deployments@2023-05-01' = [for deployment in deployments: {
  parent: account
  name: deployment.name
  properties: {
    model: deployment.model
    raiPolicyName: contains(deployment, 'raiPolicyName') ? deployment.raiPolicyName : null
  }
  sku: contains(deployment, 'sku') ? deployment.sku : {
    name: 'Standard'
    capacity: 20
  }
}]

@description('The endpoint (subdomain) of the deployed Cognitive Service.')
output endpoint string = account.properties.endpoint
@description('The resource ID of the deployed Cognitive Service.')
output id string = account.id
@description('The name of the deployed Cognitive Service.')
output name string = account.name
