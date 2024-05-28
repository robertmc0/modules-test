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
var serviceBusNamespaceTopicName = '${shortIdentifier}-servicebus-topic'
var serviceBusNamespaceDeadletterTopicName = '${shortIdentifier}-servicebus-deadletter-topic'
var serviceBusNamespaceTopicSubscriptionName = '${shortIdentifier}-servicebus-topic-sub'

var subscriptionNames = [
  '${serviceBusNamespaceTopicSubscriptionName}-0'
  '${serviceBusNamespaceTopicSubscriptionName}-1'
]

resource servicebusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

resource servicebusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: serviceBusNamespaceTopicName
  parent: servicebusNamespace
  properties: {}
}

resource servicebusDeadletterTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: serviceBusNamespaceDeadletterTopicName
  parent: servicebusNamespace
  properties: {}
}

/*======================================================================
TEST EXECUTION
======================================================================*/

module subscriptionmin '../main.bicep' = [
  for subscriptionName in subscriptionNames: {
    name: subscriptionName
    params: {
      name: subscriptionName
      autoDeleteOnIdle: 'PT5M'
      servicebusNamespaceName: serviceBusNamespaceName
      servicebusTopicName: serviceBusNamespaceTopicName
    }
    dependsOn: [
      servicebusNamespace
      servicebusTopic
    ]
  }
]

module subscriptionfull '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-topic-full-sub'
  params: {
    name: '${uniqueString(deployment().name, location)}-topic-full-sub'
    autoDeleteOnIdle: 'PT5M'
    deadLetteringOnFilterEvaluationExceptions: true
    deadLetteringOnMessageExpiration: true
    defaultMessageTimeToLive: 'P1D'
    enableBatchedOperations: true
    forwardDeadLetteredMessagesTo: serviceBusNamespaceDeadletterTopicName
    lockDuration: 'PT5M'
    maxDeliveryCount: 10
    requiresSession: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    forwardTo: serviceBusNamespaceDeadletterTopicName
    status: 'ReceiveDisabled'
    servicebusNamespaceName: serviceBusNamespaceName
    servicebusTopicName: serviceBusNamespaceTopicName
  }
  dependsOn: [
    servicebusNamespace
    servicebusTopic
    servicebusDeadletterTopic
  ]
}
