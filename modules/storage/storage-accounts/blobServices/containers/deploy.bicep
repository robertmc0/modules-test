@maxLength(24)
@description('Required. Name of the Storage Account.')
param storageAccountName string

@description('Optional. Name of the blob service.')
param blobServicesName string = 'default'

@description('Required. The name of the storage container to deploy')
param name string

@description('Optional. Name of the immutable policy.')
param immutabilityPolicyName string = 'default'

@allowed([
  'Container'
  'Blob'
  'None'
])
@description('Optional. Specifies whether data in the container may be accessed publicly and the level of access.')
param publicAccess string = 'None'

@description('Optional. Configure immutability policy.')
param immutabilityPolicyProperties object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName

  resource blobServices 'blobServices@2021-06-01' existing = {
    name: blobServicesName
  }
}

resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: name
  parent: storageAccount::blobServices
  properties: {
    publicAccess: publicAccess
  }
}

module immutabilityPolicy 'immutabilityPolicies/deploy.bicep' = if (!empty(immutabilityPolicyProperties)) {
  name: immutabilityPolicyName
  params: {
    storageAccountName: storageAccount.name
    blobServicesName: storageAccount::blobServices.name
    containerName: container.name
    immutabilityPeriodSinceCreationInDays: contains(immutabilityPolicyProperties, 'immutabilityPeriodSinceCreationInDays') ? immutabilityPolicyProperties.immutabilityPeriodSinceCreationInDays : 365
    allowProtectedAppendWrites: contains(immutabilityPolicyProperties, 'allowProtectedAppendWrites') ? immutabilityPolicyProperties.allowProtectedAppendWrites : true
  }
}

@description('The name of the deployed container')
output name string = container.name

@description('The resource ID of the deployed container')
output resourceId string = container.id

@description('The resource group of the deployed container')
output resourceGroupName string = resourceGroup().name
