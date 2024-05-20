# Servicebus Topic Module

This module deploys Microsoft.ServiceBus namespaces/topics

## Details

This module deploys a topic to an existing Azure servicebus namespace. The topic is deployed with no subscriptions.

## Parameters

| Name                         | Type     | Required | Description                                                                                                                                              |
| :--------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                       | `string` | Yes      | The resource name.                                                                                                                                       |
| `servicebusNamespaceName`    | `string` | Yes      | The servicebus namespace name.                                                                                                                           |
| `autoDeleteOnIdle`           | `string` | Yes      | Optional. ISO 8601 timespan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes.                             |
| `defaultMessageTimeToLive`   | `string` | Yes      | Optional. ISO 8601 Default message timespan to live value.                                                                                               |
| `enableBatchedOperations`    | `bool`   | No       | Optional. Value that indicates whether server-side batched operations are enabled.                                                                       |
| `enableExpress`              | `bool`   | No       | Optional. Value that indicates whether Express Entities are enabled                                                                                      |
| `enablePartitioning`         | `bool`   | No       | Optional. Value that indicates whether the topic to be partitioned across multiple message brokers is enabled.                                           |
| `maxMessageSizeInKilobytes`  | `int`    | No       | Optonal. Maximum size (in KB) of the message payload that can be accepted by the topic. This property is only used in Premium today and default is 1024. |
| `maxSizeInMegabytes`         | `int`    | No       | Optional. Maximum size of the topic in megabytes, which is the size of the memory allocated for the topic. Default is 1024.                              |
| `requiresDuplicateDetection` | `bool`   | No       | Optional. Value indicating if this topic requires duplicate detection.                                                                                   |
| `status`                     | `string` | No       | Optional. Enumerates the possible values for the status of a messaging entity.                                                                           |
| `supportOrdering`            | `bool`   | No       | Optional. Value that indicates whether the topic supports ordering.                                                                                      |

## Outputs

| Name         | Type     | Description                  |
| :----------- | :------: | :--------------------------- |
| `name`       | `string` | The name of the Topic        |
| `resourceId` | `string` | The resource ID of the Topic |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.