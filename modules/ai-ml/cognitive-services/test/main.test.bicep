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

@description('The storage account resource name.')
param storageName string = 'sa${uniqueString(deployment().name, location)}'

@description('The log analytics resource name.')
param logAnalyticsName string = 'law-${uniqueString(deployment().name, location)}'

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

param cognitiveServiceDiagsName string = 'diags-${uniqueString(deployment().name, location)}'

param cognitiveServiceDiagsSku string = 'S0'

param cognitiveServiceDiagsDeployments array = []

/*======================================================================
TEST PREREQUISITES
======================================================================*/

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {//name needs to be addressed
  name: storageName
  location: location
  kind: 'BlobStorage'
  properties: {
    accessTier: 'Hot'
  }
  sku: {
    name: 'Standard_GRS'
  }
}

resource diagnosticsStorageAccountPolicy 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = {
  parent: storage
  name: 'default'
  properties: {
    policy: {
      rules: [
        {
          name: 'blob-lifecycle'
          type: 'Lifecycle'
          definition: {
            actions: {
              baseBlob: {
                tierToCool: {
                  daysAfterModificationGreaterThan: 30
                }
                delete: {
                  daysAfterModificationGreaterThan: 365
                }
              }
              snapshot: {
                delete: {
                  daysAfterCreationGreaterThan: 365
                }
              }
            }
            filters: {
              blobTypes: [
                'blockBlob'
              ]
            }
          }
        }
      ]
    }
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}

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

module diagnosticsEnabled '../main.bicep' = {
  name: 'diags-${uniqueString(deployment().name, location)}'
  params: {
    name: cognitiveServiceDiagsName
    location: location
    kind: 'CognitiveServices'
    tags: tags
    sku: cognitiveServiceDiagsSku
    deployments: cognitiveServiceDiagsDeployments
    resourcelock: 'CanNotDelete'
    enableDiagnostics: true
    diagnosticLogAnalyticsWorkspaceId: logAnalytics.id
  }
}
