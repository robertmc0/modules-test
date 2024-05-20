metadata name = 'Servicebus Topic Module'
metadata description = 'This module deploys Microsoft.ServiceBus namespaces/topics/subscription'
metadata owner = 'Arinco'

@description('The resource name.')
param name string

@description('The servicebus namespace name.')
param servicebusNamespaceName string

@description('The servicebus topic name.')
param servicebusTopicName string

@description('Optional. ISO 8601 timespan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes.')
param autoDeleteOnIdle string

@description('Optional. Value that indicates whether a subscription has dead letter support on filter evaluation exceptions.')
param deadLetteringOnFilterEvaluationExceptions bool = false

@description('Optional. Value that indicates whether a subscription has dead letter support when a message expires.')
param deadLetteringOnMessageExpiration bool = false

@description('Optional. ISO 8061 Default message timespan to live value. ')
param defaultMessageTimeToLive string = 'P10675199DT2H48M5.4775807S'

@description('Optional. ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.')
param duplicateDetectionHistoryTimeWindow string = 'PT10M'

@description('Optonal. Value that indicates whether server-side batched operations are enabled.')
param enableBatchedOperations bool = false

@description('Optional. Queue/Topic name to forward the Dead Letter message')
param forwardDeadLetteredMessagesTo string = ''

@description('Optional. Queue/Topic name to forward the messages.')
param forwardTo string = ''

@description('Optional. Enumerates the possible values for the status of a messaging entity.')
@allowed([
  'Active'
  'Creating'
  'Deleting'
  'Disabled'
  'ReceiveDisabled'
  'Renaming'
  'Restoring'
  'SendDisabled'
  'Unknown'
])
param status string = 'Active'

@description('Optional. ISO 8061 lock duration timespan for the subscription. The default value is 1 minute.')
param lockDuration string = 'PT1M'

@description('The maximum delivery count. A message is automatically deadlettered after this number of deliveries.')
param maxDeliveryCount int

@description('Optional. Value that indicates whether the subscription supports the concept of session.')
param requiresSession bool = false

resource servicebusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' existing = {
  name: '${servicebusNamespaceName}/${servicebusTopicName}'
}

resource topicSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name: name
  parent: servicebusTopic
  properties: {
    autoDeleteOnIdle: autoDeleteOnIdle
    deadLetteringOnFilterEvaluationExceptions: deadLetteringOnFilterEvaluationExceptions
    deadLetteringOnMessageExpiration: deadLetteringOnMessageExpiration
    defaultMessageTimeToLive: defaultMessageTimeToLive
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    enableBatchedOperations: enableBatchedOperations
    forwardDeadLetteredMessagesTo: empty(forwardDeadLetteredMessagesTo) ? null : forwardDeadLetteredMessagesTo
    forwardTo: empty(forwardTo) ? null : forwardTo
    lockDuration: lockDuration
    maxDeliveryCount: maxDeliveryCount
    requiresSession: requiresSession
    status: status
  }
}

@description('The name of the topic subscription')
output servicebusName string = topicSubscription.name

@description('The name of the Topic')
output name string = servicebusTopic.name
