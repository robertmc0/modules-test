# Front Door Profiles Module

This module deploys Microsoft.Cdn front door profiles

## Description

This module performs the following

- Creates Microsoft.Cdn Front Door profiles resource.
- Applies system managed or user assigned identities if provided.
- Applies diagnostic settings.
- Applies a lock to the application gateway if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                   |
| :-------------------------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The name of the front door profile to create. This must be globally unique.                                                                   |
| `skuName`                               | `string` | Yes      | The name of the SKU to use when creating the Front Door profile.                                                                              |
| `originResponseTimeoutSeconds`          | `int`    | No       | Optional. Specifies the send and receive timeout on forwarding request to the origin. When timeout is reached, the request fails and returns. |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                           |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                      |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                                |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                                  |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                          |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                              |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                          |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                     |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                             |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                  |

## Outputs

| Name       | Type   | Description                                              |
| :--------- | :----: | :------------------------------------------------------- |
| name       | string | The name of the deployed Azure Frontdoor Profile.        |
| resourceId | string | The resource Id of the deployed Azure Frontdoor Profile. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.