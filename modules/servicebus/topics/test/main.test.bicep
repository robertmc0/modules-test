/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
var serviceBusNamespaceName = '${shortIdentifier}-sb-servicebustest-aue'

resource servicebusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

/*======================================================================
TEST EXECUTION
======================================================================*/

module topicmin '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-topic'
  params: {
    name: '${uniqueString(deployment().name, location)}-topic'
    autoDeleteOnIdle: 'PT5M'
    defaultMessageTimeToLive: 'PT5M'
    servicebusNamespaceName: serviceBusNamespaceName
  }
  dependsOn: [
    servicebusNamespace
  ]
}

module topicfull '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-full-topic'
  params: {
    name: '${uniqueString(deployment().name, location)}-full-topic'
    autoDeleteOnIdle: 'PT5M'
    defaultMessageTimeToLive: 'PT5M'
    servicebusNamespaceName: serviceBusNamespaceName
    enableBatchedOperations: true
    enableExpress: true
    enablePartitioning: true
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    maxMessageSizeInKilobytes: 1024
    status: 'Active'
    supportOrdering: true
  }
  dependsOn: [
    servicebusNamespace
  ]
}
