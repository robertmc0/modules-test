# Application Groups Module

This module deploys Microsoft.DesktopVirtualization applicationGroups

## Description

- Creates Microsoft.DesktopVirtualization applicationGroups resource.
- Applies diagnostic settings if specified.
- Applies a resource lock if specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `friendlyName`                          | `string` | No       | Optional. Friendly name of ApplicationGroup.                                                                            |
| `applicationGroupDescription`           | `string` | No       | Optional. Description for ApplicationGroup.                                                                             |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `applicationGroupType`                  | `string` | Yes      | Resource Type of ApplicationGroup.                                                                                      |
| `hostPoolArmPath`                       | `string` | Yes      | HostPool arm path of ApplicationGroup.                                                                                  |
| `remoteApps`                            | `array`  | No       | Optional. RemoteApps to add to ApplicationGroup.                                                                        |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.          |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |

## Outputs

| Name       | Type   | Description                                        |
| :--------- | :----: | :------------------------------------------------- |
| name       | string | The name of the deployed application group.        |
| resourceId | string | The resource ID of the deployed application group. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.