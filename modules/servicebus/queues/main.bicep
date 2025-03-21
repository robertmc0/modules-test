metadata name = 'Servicebus Topic Module'
metadata description = 'This module deploys Microsoft.ServiceBus namespaces/queues'
metadata owner = 'Arinco'

@description('The resource name.')
param name string

@description('The servicebus namespace name.')
param servicebusNamespaceName string

@description('ISO 8601 timespan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes.')
param autoDeleteOnIdle string

@description('Optional. Value that indicates whether a queue has dead letter support when a message expires.')
param deadLetteringOnMessageExpiration bool = false

@description('Optional. ISO 8601 Default message timespan to live value. ')
param defaultMessageTimeToLive string

@description('Optional. Value that indicates whether server-side batched operations are enabled.')
param enableBatchedOperations bool = false

@description('Optional. Value that indicates whether Express Entities are enabled')
param enableExpress bool = false

@description('Optional. ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.')
param duplicateDetectionHistoryTimeWindow string = 'PT10M'

@description('Optional. Value that indicates whether the topic to be partitioned across multiple message brokers is enabled.')
param enablePartitioning bool = false

@description('Optonal. Maximum size (in KB) of the message payload that can be accepted by the topic. This property is only used in Premium today and default is 1024.')
param maxMessageSizeInKilobytes int = 1024

@description('Optional. Queue/Topic name to forward the Dead Letter message')
param forwardDeadLetteredMessagesTo string = ''

@description('Optional. Queue/Topic name to forward the messages.')
param forwardTo string = ''

@description('Optional. Maximum size of the topic in megabytes, which is the size of the memory allocated for the topic. Default is 1024.')
param maxSizeInMegabytes int = 1024

@description('Optional. Value indicating if this topic requires duplicate detection.')
param requiresDuplicateDetection bool = false

@description('Optional. Enumerates the possible values for the status of a messaging entity.')
@allowed([
  'Active'
  'Disabled'
  'ReceiveDisabled'
  'SendDisabled'
])
param status string = 'Active'

@description('Optional. ISO 8061 lock duration timespan for the subscription. The default value is 1 minute.')
param lockDuration string = 'PT1M'

@description('Optional. The maximum delivery count. A message is automatically deadlettered after this number of deliveries. Default value is 10.')
param maxDeliveryCount int = 10

@description('Optional. Value that indicates whether the queue supports the concept of session.')
param requiresSession bool = false

resource servicebusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: servicebusNamespaceName
}

resource servcebusQueue 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = {
  name: name
  parent: servicebusNamespace
  properties: {
    autoDeleteOnIdle: autoDeleteOnIdle
    deadLetteringOnMessageExpiration: deadLetteringOnMessageExpiration
    defaultMessageTimeToLive: defaultMessageTimeToLive
    duplicateDetectionHistoryTimeWindow: duplicateDetectionHistoryTimeWindow
    enableBatchedOperations: enableBatchedOperations
    enableExpress: enableExpress
    enablePartitioning: enablePartitioning
    forwardDeadLetteredMessagesTo: empty(forwardDeadLetteredMessagesTo) ? null : forwardDeadLetteredMessagesTo
    forwardTo: empty(forwardTo) ? null : forwardTo
    lockDuration: lockDuration
    maxDeliveryCount: maxDeliveryCount
    maxMessageSizeInKilobytes: servicebusNamespace.sku == 'Premium' ? maxMessageSizeInKilobytes : null
    maxSizeInMegabytes: maxSizeInMegabytes
    requiresDuplicateDetection: requiresDuplicateDetection
    requiresSession: requiresSession
    status: status
  }
}

@description('The name of the Queue')
output name string = servcebusQueue.name

@description('The resource ID of the Queue')
output resourceId string = servcebusQueue.id
