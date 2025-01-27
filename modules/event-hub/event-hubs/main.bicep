metadata name = 'EventHub Module'
metadata description = 'This module deploys an EventHub (Microsoft.EventHub/namespaces/EventHubs) resource.'
metadata owner = 'Arinco'

@description('The name of the resource.')
param name string

@description('How many days to retain the message.')
param messageRetentionInDays int

@description('Number of partitions in the Event Hub.')
param partitionCount int

@description('Resource ID of the EventHub namespace to associate Event Hub to.')
param scope string

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${name}-${resourceLock}-lck')

resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' existing = {
  name: scope
}

resource eventHubNamespaceEventHub 'Microsoft.EventHub/namespaces/EventHubs@2024-01-01' = {
  parent: eventHubNamespace
  name: name
  properties: {
    messageRetentionInDays: messageRetentionInDays
    partitionCount: partitionCount
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: eventHubNamespaceEventHub
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed resource.')
output name string = eventHubNamespaceEventHub.name

@description('The resource ID of the deployed resource.')
output resourceId string = eventHubNamespaceEventHub.id
