# Scaling Plans Module

This module deploys Microsoft.DesktopVirtualization scalingPlans

## Description

- Creates Microsoft.DesktopVirtualization scalingPlans resource.
- Applies diagnostic settings if specified.
- Applies a resource lock if specified.

> Note: In order to deploy scaling plans you must assign the Desktop Virtualization Power On Off Contributor role to the Azure Virtual Desktop service principal. See reference article [here](https://learn.microsoft.com/en-us/azure/virtual-desktop/autoscale-scaling-plan#assign-the-desktop-virtualization-power-on-off-contributor-role-with-the-azure-portal).

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `friendlyName`                          | `string` | No       | Optional. Friendly name of scaling plan.                                                                                |
| `scalingPlanDescription`                | `string` | No       | Optional. Description for scaling plan.                                                                                 |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `exclusionTag`                          | `string` | No       | Optional. Exclusion tag for scaling plan.                                                                               |
| `hostPoolReferences`                    | `array`  | Yes      | List of HostPool resource Ids.                                                                                          |
| `timeZone`                              | `string` | Yes      | Timezone of the scaling plan. E.g. "AUS Eastern Standard Time".                                                         |
| `schedules`                             | `array`  | Yes      | List of scaling plan definitions.                                                                                       |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.          |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |

## Outputs

| Name       | Type   | Description                                   |
| :--------- | :----: | :-------------------------------------------- |
| name       | string | The name of the deployed scaling plan.        |
| resourceId | string | The resource ID of the deployed scaling plan. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.