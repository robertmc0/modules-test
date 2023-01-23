# Host Pools Module

This module deploys Microsoft.DesktopVirtualization hostPools

## Description

- Creates Microsoft.DesktopVirtualization hostPools resource.
- Applies diagnostic settings if specified.
- Applies a resource lock if specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `friendlyName`                          | `string` | No       | Optional. Friendly name of HostPool.                                                                                    |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `hostPoolDescription`                   | `string` | No       | Optional. Description for HostPool.                                                                                     |
| `hostPoolType`                          | `string` | Yes      | HostPool type for desktop.                                                                                              |
| `loadBalancerType`                      | `string` | No       | Optional. The type of the load balancer.                                                                                |
| `maxSessionLimit`                       | `int`    | No       | Optional. The max session limit of HostPool.                                                                            |
| `preferredAppGroupType`                 | `string` | No       | Optional. The type of preferred application group type, default to Desktop Application Group.                           |
| `registrationInfo`                      | `object` | Yes      | The registration info of HostPool.                                                                                      |
| `startVMOnConnect`                      | `bool`   | No       | Optional. The flag to turn on/off StartVMOnConnect feature.                                                             |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.          |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |

## Outputs

| Name       | Type   | Description                                |
| :--------- | :----: | :----------------------------------------- |
| name       | string | The name of the deployed host pool.        |
| resourceId | string | The resource ID of the deployed host pool. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.