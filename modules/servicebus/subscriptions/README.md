# Servicebus Topic Module

This module deploys Microsoft.ServiceBus namespaces/topics/subscription

## Details

This module deploys a subscription to an existing Azure Servicebus namespace topic.

## Parameters

| Name                                        | Type     | Required | Description                                                                                                                          |
| :------------------------------------------ | :------: | :------: | :----------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                      | `string` | Yes      | The resource name.                                                                                                                   |
| `servicebusNamespaceName`                   | `string` | Yes      | The servicebus namespace name.                                                                                                       |
| `servicebusTopicName`                       | `string` | Yes      | The servicebus topic name.                                                                                                           |
| `autoDeleteOnIdle`                          | `string` | Yes      | Optional. ISO 8601 timespan idle interval after which the topic is automatically deleted. The minimum duration is 5 minutes.         |
| `deadLetteringOnFilterEvaluationExceptions` | `bool`   | No       | Optional. Value that indicates whether a subscription has dead letter support on filter evaluation exceptions.                       |
| `deadLetteringOnMessageExpiration`          | `bool`   | No       | Optional. Value that indicates whether a subscription has dead letter support when a message expires.                                |
| `defaultMessageTimeToLive`                  | `string` | No       | Optional. ISO 8061 Default message timespan to live value.                                                                           |
| `duplicateDetectionHistoryTimeWindow`       | `string` | No       | Optional. ISO 8601 timeSpan structure that defines the duration of the duplicate detection history. The default value is 10 minutes. |
| `enableBatchedOperations`                   | `bool`   | No       | Optonal. Value that indicates whether server-side batched operations are enabled.                                                    |
| `forwardDeadLetteredMessagesTo`             | `string` | No       | Optional. Queue/Topic name to forward the Dead Letter message                                                                        |
| `forwardTo`                                 | `string` | No       | Optional. Queue/Topic name to forward the messages.                                                                                  |
| `status`                                    | `string` | No       | Optional. Enumerates the possible values for the status of a messaging entity.                                                       |
| `lockDuration`                              | `string` | No       | Optional. ISO 8061 lock duration timespan for the subscription. The default value is 1 minute.                                       |
| `maxDeliveryCount`                          | `int`    | Yes      | The maximum delivery count. A message is automatically deadlettered after this number of deliveries.                                 |
| `requiresSession`                           | `bool`   | No       | Optional. Value that indicates whether the subscription supports the concept of session.                                             |

## Outputs

| Name             | Type     | Description                        |
| :--------------- | :------: | :--------------------------------- |
| `servicebusName` | `string` | The name of the topic subscription |
| `name`           | `string` | The name of the Topic              |