# Operational Insights Workspace Module.

This module deploys Microsoft.OperationalInsights workspaces, aka Log Analytics workspaces.

## Description

This module performs the following

- Creates Microsoft.OperationalInsights workspaces resource.
- Adds data sources if specified.
- Adds solutions if specified.
- Links workspace to an automation account if specified.
- Applies diagnostic settings if specified.
- Applies a lock to the storage account if specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                       |
| :-------------------------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                        |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                          |
| `sku`                                   | `string` | No       | Optional. The SKU of the workspace.                                                                                               |
| `retentionInDays`                       | `int`    | No       | Optional. The workspace data retention in days. Allowed values are per pricing plan. See pricing tiers documentation for details. |
| `solutions`                             | `array`  | No       | Optional. Solutions to add to workspace.                                                                                          |
| `automationAccountId`                   | `string` | No       | Optional. Resource id of automation account to link to workspace.                                                                 |
| `dataSources`                           | `array`  | No       | Optional. Datasources to add to workspace.                                                                                        |
| `savedSearches`                         | `array`  | No       | Optional. Saved searches to add to workspace.                                                                                     |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                      |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logs                                                                                                  |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                  |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                              |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                    |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                         |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                 |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.           |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                      |

## Outputs

| Name       | Type   | Description                                              |
| :--------- | :----: | :------------------------------------------------------- |
| name       | string | The name of the deployed log analytics workspace.        |
| resourceId | string | The resource ID of the deployed log analytics workspace. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.