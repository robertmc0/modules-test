# Sql Elastic Pool

This module deploys Microsoft.Sql.Server Elastic Pool

## Description

This module performs the following

- Creates Microsoft.Sql elastic pool resource.
- Applies diagnostic settings if specified (only metrics available).
- Applies a lock to the elastic pool if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | Name of Elastic Pool to create.                                                                                                                            |
| `location`                              | `string` | Yes      | Location of resource.                                                                                                                                      |
| `sqlServerName`                         | `string` | Yes      | Name of existing Azure SQL Server.                                                                                                                         |
| `skuType`                               | `string` | Yes      | A predefined set of SkuTypes. Currently template not configured to support Hyper-Scale or Business Critical.                                               |
| `skuCapacity`                           | `int`    | Yes      | Capacity of Elastic Pool.  If DTU model, define amount of DTU. If vCore model, define number of vCores.                                                    |
| `databaseMinCapacity`                   | `string` | No       | Optional. Minimum capacity per database.  If DTU model, define amount of DTU. If vCore model, define number of vCores. Requires string to handle decimals. |
| `databaseMaxCapacity`                   | `int`    | No       | Optional. Maximum capacity per database.  If DTU model, define amount of DTU. If vCore model, define number of vCores.                                     |
| `maxPoolSize`                           | `int`    | Yes      | Maximum size in bytes for the Elastic Pool.                                                                                                                |
| `zoneRedundant`                         | `bool`   | No       | Optional. Whether the databases in pool zone redundant. Only supported in some regions.                                                                    |
| `licenseType`                           | `string` | No       | Optional. For Azure Hybrid Benefit, use BasePrice.                                                                                                         |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                   |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of lock.                                                                                                                        |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                       |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Resource ID of the diagnostic log analytics workspace.                                                                                           |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.   |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                             |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Resource ID of the diagnostic storage account.                                                                                                   |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                       |

## Outputs

| Name       | Type   | Description                          |
| :--------- | :----: | :----------------------------------- |
| name       | string | The name of the elastic pool.        |
| resourceId | string | The resource ID of the elastic pool. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.