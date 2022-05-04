@maxLength(24)
@description('Required. Name of the Storage Account.')
param storageAccountName string

@description('Optional. The name of the queue service')
param queueServicesName string = 'default'

@description('Required. The name of the storage queue to deploy')
param name string

@description('Required. A name-value pair that represents queue metadata.')
param metadata object = {}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName

  resource queueServices 'queueServices@2021-06-01' existing = {
    name: queueServicesName
  }
}

resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2019-06-01' = {
  name: name
  parent: storageAccount::queueServices
  properties: {
    metadata: metadata
  }
}

@description('The name of the deployed queue')
output name string = queue.name

@description('The resource ID of the deployed queue')
output resourceId string = queue.id

@description('The resource group of the deployed queue')
output resourceGroupName string = resourceGroup().name
