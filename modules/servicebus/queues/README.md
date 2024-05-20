# Servicebus Topic Module

This module deploys Microsoft.ServiceBus namespaces/queues

## Details

This modules deploys queue to an existing Azure servicebus namespace.

## Parameters

| Name                                  | Type     | Required | Description                                                                                                                                              |
| :------------------------------------ | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                | `string` | Yes      | The resource name.                                                                                                                                       |
| `servicebusNamespaceName`             | `string` | Yes      | The servicebus namespace name.                                                                                                                           |
| `autoDeleteOnIdle`                    | `string` | Yes      | Optional. ISO 8601 timespan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes.                             |
| `deadLetteringOnMessageExpiration`    | `bool`   | No       | Optional. Value that indicates whether a queue has dead letter support when a message expires.                                                           |
| `defaultMessageTimeToLive`            | `string` | Yes      | Optional. ISO 8601 Default message timespan to live value.                                                                                               |
| `enableBatchedOperations`             | `bool`   | No       | Optional. Value that indicates whether server-side batched operations are enabled.                                                                       |
| `enableExpress`                       | `bool`   | No       | Optional. Value that indicates whether Express Entities are enabled                                                                                      |
| `duplicateDetectionHistoryTimeWindow` | `string` | No       | Optional. ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes.                     |
| `enablePartitioning`                  | `bool`   | No       | Optional. Value that indicates whether the topic to be partitioned across multiple message brokers is enabled.                                           |
| `maxMessageSizeInKilobytes`           | `int`    | No       | Optonal. Maximum size (in KB) of the message payload that can be accepted by the topic. This property is only used in Premium today and default is 1024. |
| `forwardDeadLetteredMessagesTo`       | `string` | No       | Optional. Queue/Topic name to forward the Dead Letter message                                                                                            |
| `forwardTo`                           | `string` | No       | Optional. Queue/Topic name to forward the messages.                                                                                                      |
| `maxSizeInMegabytes`                  | `int`    | No       | Optional. Maximum size of the topic in megabytes, which is the size of the memory allocated for the topic. Default is 1024.                              |
| `requiresDuplicateDetection`          | `bool`   | No       | Optional. Value indicating if this topic requires duplicate detection.                                                                                   |
| `status`                              | `string` | No       | Optional. Enumerates the possible values for the status of a messaging entity.                                                                           |
| `lockDuration`                        | `string` | No       | Optional. ISO 8061 lock duration timespan for the subscription. The default value is 1 minute.                                                           |
| `maxDeliveryCount`                    | `int`    | Yes      | The maximum delivery count. A message is automatically deadlettered after this number of deliveries.                                                     |
| `requiresSession`                     | `bool`   | No       | Optional. Value that indicates whether the queue supports the concept of session.                                                                        |

## Outputs

| Name         | Type     | Description                  |
| :----------- | :------: | :--------------------------- |
| `name`       | `string` | The name of the Queue        |
| `resourceId` | `string` | The resource ID of the Queue |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.