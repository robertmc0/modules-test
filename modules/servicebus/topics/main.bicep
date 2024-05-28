metadata name = 'Servicebus Topic Module'
metadata description = 'This module deploys Microsoft.ServiceBus namespaces/topics'
metadata owner = 'Arinco'

@description('The resource name.')
param name string

@description('The servicebus namespace name.')
param servicebusNamespaceName string

@description('ISO 8601 timespan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes.')
param autoDeleteOnIdle string

@description('ISO 8601 Default message timespan to live value.')
param defaultMessageTimeToLive string

@description('Optional. Value that indicates whether server-side batched operations are enabled.')
param enableBatchedOperations bool = false

@description('Optional. Value that indicates whether Express Entities are enabled')
param enableExpress bool = false

@description('Optional. Value that indicates whether the topic to be partitioned across multiple message brokers is enabled.')
param enablePartitioning bool = false

@description('Optonal. Maximum size (in KB) of the message payload that can be accepted by the topic. This property is only used in Premium today and default is 1024.')
param maxMessageSizeInKilobytes int = 1024

@description('Optional. Maximum size of the topic in megabytes, which is the size of the memory allocated for the topic. Default is 1024.')
param maxSizeInMegabytes int = 1024

@description('Optional. Value indicating if this topic requires duplicate detection.')
param requiresDuplicateDetection bool = false

@description('Optional. Enumerates the possible values for the status of a messaging entity.')
@allowed([
  'Active'
  'Disabled'
  'ReceiveDisabled'
])
param status string = 'Active'

@description('Optional. Value that indicates whether the topic supports ordering.')
param supportOrdering bool = false

resource servicebusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: servicebusNamespaceName
}

resource servicebusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: name
  parent: servicebusNamespace
  properties: {
    autoDeleteOnIdle: autoDeleteOnIdle
    defaultMessageTimeToLive: defaultMessageTimeToLive
    enableBatchedOperations: enableBatchedOperations
    enableExpress: enableExpress
    enablePartitioning: enablePartitioning
    maxMessageSizeInKilobytes: servicebusNamespace.sku == 'Premium' ? maxMessageSizeInKilobytes : null
    maxSizeInMegabytes: maxSizeInMegabytes
    requiresDuplicateDetection: requiresDuplicateDetection
    status: status
    supportOrdering: supportOrdering
  }
}

@description('The name of the Topic')
output name string = servicebusTopic.name

@description('The resource ID of the Topic')
output resourceId string = servicebusTopic.id
