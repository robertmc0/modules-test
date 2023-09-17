/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

param cognitiveServiceOpenAIName string = 'openai-${uniqueString(deployment().name, location)}'

param cognitiveServiceOpenAISku string = 'S0'

param cognitiveServiceOpenAIDeployments array = [
  {
    name: 'davinci'
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0301'
    }
    sku: {
      name: 'Standard'
      capacity: 30
    }
  }
  {
    name: 'chat'
    model: {
      format: 'OpenAI'
      name: 'gpt-35-turbo'
      version: '0301'
    }
    sku: {
      name: 'Standard'
      capacity: 30
    }
  }
]

param cognitiveServiceComputerVisionName string = 'computervision-${uniqueString(deployment().name, location)}'

param cognitiveServiceComputerVisionSku string = 'F0'

param cognitiveServiceComputerVisionDeployments array = []

param cognitiveServiceTextTranslationName string = 'texttranslation-${uniqueString(deployment().name, location)}'

param cognitiveServiceTextTranslationSku string = 'F0'

param cognitiveServiceTextTranslationDeployments array = []

param cognitiveServiceUniversalKeyName string = 'universalkey-${uniqueString(deployment().name, location)}'

param cognitiveServiceUniversalKeySku string = 'S0'

param cognitiveServiceUniversalKeyDeployments array = []

param cognitiveServiceUniversalKeyProperties object = {
  customSubDomainName: cognitiveServiceUniversalKeyName
  publicNetworkAccess: 'Enabled'
  apiProperties: {
    statisticsEnabled: false
  }
}

/*======================================================================
TEST PREREQUISITES
======================================================================*/

/*======================================================================
TEST EXECUTION
======================================================================*/

module openAI '../main.bicep' = {
  name: 'openai-${uniqueString(deployment().name, location)}'
  params: {
    name: cognitiveServiceOpenAIName
    location: location
    tags: tags
    sku: cognitiveServiceOpenAISku
    deployments: cognitiveServiceOpenAIDeployments
  }
}

module computerVision '../main.bicep' = {
  name: 'computervision-${uniqueString(deployment().name, location)}'
  params: {
    name: cognitiveServiceComputerVisionName
    location: location
    kind: 'ComputerVision'
    tags: tags
    sku: cognitiveServiceComputerVisionSku
    deployments: cognitiveServiceComputerVisionDeployments
  }
}

module textTranslation '../main.bicep' = {
  name: 'texttranslation-${uniqueString(deployment().name, location)}'
  params: {
    name: cognitiveServiceTextTranslationName
    location: location
    kind: 'TextTranslation'
    tags: tags
    sku: cognitiveServiceTextTranslationSku
    deployments: cognitiveServiceTextTranslationDeployments
  }
}

module cognitiveServiceUniversalKey '../main.bicep' = {
  name: 'universalkey-${uniqueString(deployment().name, location)}'
  params: {
    name: cognitiveServiceUniversalKeyName
    location: location
    kind: 'CognitiveServices'
    tags: tags
    sku: cognitiveServiceUniversalKeySku
    deployments: cognitiveServiceUniversalKeyDeployments
    properties: cognitiveServiceUniversalKeyProperties
  }
}
