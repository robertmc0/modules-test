# EventHub Namespace Module

This module deploys an EventHub Namespace (Microsoft.EventHub/namespaces) resource.

## Details

This module deploys an EventHub Namespace (Microsoft.EventHub/namespaces) resource. Also includes diagnostics and lock.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `name`                                  | `string` | Yes      | The name of the resource.                                                                                               |
| `sku`                                   | `string` | Yes      | The SKU of the resource.                                                                                                |
| `isAutoInflateEnabled`                  | `bool`   | Yes      | isAutoInflateEnabled                                                                                                    |
| `maximumThroughputUnits`                | `int`    | Yes      | maximumThroughputUnits                                                                                                  |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |

## Outputs

| Name         | Type     | Description                               |
| :----------- | :------: | :---------------------------------------- |
| `name`       | `string` | The name of the deployed resource.        |
| `resourceId` | `string` | The resource ID of the deployed resource. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.