@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

module names '../../../naming/conventions/main.bicep' = {
  scope: subscription()
  name: '${uniqueString(deployment().name, location)}-naming'
  params: {
    location: location
    prefixes: [
      'ar'
      '**location**'
    ]
    suffixes: [
      'bicep'
      'validation'
    ]
  }
}

module eventHubNamespace '../../namespaces/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-ehn'
  params: {
    name: names.outputs.names.eventHubNamespace.name
    location: location
    sku: 'Standard'
    isAutoInflateEnabled: true
    maximumThroughputUnits: 7
    tags: {}
  }
}

module eventHubNamespaceEventHub '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-ehneh'
  params: {
    name: names.outputs.names.eventHubNamespaceEventHub.name
    messageRetentionInDays: 1
    partitionCount: 2
    scope: names.outputs.names.eventHubNamespace.name
    tags: {}
  }
}
