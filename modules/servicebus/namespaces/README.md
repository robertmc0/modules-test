# Servicebus Module

This module deploys Servicebus Namespace resource.

## Details

This module creates a servicebus namespace with the passed name and location. The module is scoped to a resource group where the namespace has to be created.

The namespace is created without any topic or queues.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`                              | `string` | Yes      | Location for all Resources.                                                                                                                                |
| `name`                                  | `string` | Yes      | The name of the of the Servicebus Namespace.                                                                                                               |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of lock.                                                                                                                        |
| `sku`                                   | `string` | No       | Optional. The pricing tier of this Servicebus Namespace                                                                                                    |
| `capacity`                              | `int`    | No       | Optional. The Messaging units for your service bus premium namespace.                                                                                      |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                                        |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                   |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                                             |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                           |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                       |
| `premiumMessagingPartitions`            | `int`    | No       | Optional. The number of partitions of a Service Bus namespace. Attribute applicable for premium servicebus.                                                |
| `disableLocalAuthentication`            | `bool`   | No       | Optional. Diabled SAS Authentication.                                                                                                                      |
| `enableZoneRedundancy`                  | `bool`   | No       | Optional. Enable zone redundancy .                                                                                                                         |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                       |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Resource ID of the diagnostic log analytics workspace.                                                                                           |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.   |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Resource ID of the diagnostic storage account.                                                                                                   |

## Outputs

| Name         | Type     | Description                                 |
| :----------- | :------: | :------------------------------------------ |
| `name`       | `string` | The name of the Servicebus Namespace        |
| `resourceId` | `string` | The resource ID of the Servicebus Namespace 