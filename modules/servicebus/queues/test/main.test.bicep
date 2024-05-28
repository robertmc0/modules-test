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
var serviceBusNamespaceName = '${shortIdentifier}-sbn-servicebustest-aue'
var serviceBusNamespaceQueueMinNames = [
  '${shortIdentifier}-queue-01'
  '${shortIdentifier}-queue-02'
]
var serviceBusNamespaceQueueFullName = '${shortIdentifier}-full-queue'

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

module queuemin '../main.bicep' = [
  for queueName in serviceBusNamespaceQueueMinNames: {
    name: queueName
    params: {
      name: queueName
      autoDeleteOnIdle: 'PT5M'
      defaultMessageTimeToLive: 'PT5M'
      servicebusNamespaceName: serviceBusNamespaceName
    }
    dependsOn: [
      servicebusNamespace
    ]
  }
]

module queuefull '../main.bicep' = {
  name: serviceBusNamespaceQueueFullName
  params: {
    name: serviceBusNamespaceQueueFullName
    autoDeleteOnIdle: 'PT5M'
    defaultMessageTimeToLive: 'PT5M'
    maxDeliveryCount: 5
    deadLetteringOnMessageExpiration: true
    duplicateDetectionHistoryTimeWindow: 'PT5M'
    enableBatchedOperations: true
    enableExpress: true
    enablePartitioning: true
    forwardDeadLetteredMessagesTo: serviceBusNamespaceQueueMinNames[0]
    forwardTo: serviceBusNamespaceQueueMinNames[1]
    lockDuration: 'PT5M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
    maxMessageSizeInKilobytes: 1024
    status: 'ReceiveDisabled'
    servicebusNamespaceName: serviceBusNamespaceName
  }
  dependsOn: [
    servicebusNamespace
    queuemin
  ]
}
