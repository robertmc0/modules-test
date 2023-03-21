# Sql Elastic Pool Module

This module deploys Microsoft.Sql Elastic Pool.

## Description

This module performs the following

- Creates Microsoft.Sql elastic pool resource.
- Applies diagnostic settings if specified (only metrics available).
- Applies a lock to the elastic pool if the lock is specified.

## Parameters

| Name                                    | Type           | Required | Description                                                                                                                                          |
| :-------------------------------------- | :------------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string`       | Yes      | The resource name.                                                                                                                                   |
| `location`                              | `string`       | Yes      | The geo-location where the resource lives.                                                                                                           |
| `tags`                                  | `object`       | No       | Optional. Resource tags.                                                                                                                             |
| `skuType`                               | `string` | Yes      | A predefined set of SkuTypes. Currently template not configured to support Hyper-Scale or Business Critical.                                               |
| `skuCapacity`                           | `int`    | Yes      | Total capacity of Elastic Pool. If DTU model, define amount of DTU. If vCore model, define number of vCores.                                                          |
| `databaseMinCapacity`                        | `string` | No       | Optional. Per database min capacity allocation. If DTU model, define amount of DTU. If vCore model, define number of vCores. Requires string to handle decimals.                                            |
| `databaseMaxCapacity`                        | `int` | No       | Optional. Per database max capacity allocation. If DTU model, define amount of DTU. If vCore model, define number of vCores.                                            |
| `maxPoolSize`                             | `int`    | Yes      | Maximum size in bytes for elastic pool.            |
| `zoneRedundant`                         | `bool`   | No       | Optional. Whether the elastic pool is zone redundant. Only supported in some regions.                                                                        |
| `licenseType`                           | `string` | No       | Optional. For Azure Hybrid Benefit, use BasePrice.                                                                                                         |
| `enableDiagnostics`                     | `bool`         | No       | Optional. Enable diagnostic logging.                                                                                                                 |
| `diagnosticMetricsToEnable`             | `array`        | No       | Optional. The name of metrics that will be streamed.                                                                                                 |
| `diagnosticLogsRetentionInDays`         | `int`          | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                       |
| `diagnosticStorageAccountId`            | `string`       | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                            |
| `diagnosticLogAnalyticsWorkspaceId`     | `string`       | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                    |
| `diagnosticEventHubAuthorizationRuleId` | `string`       | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                              |
| `diagnosticEventHubName`                | `string`       | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                         |
| `resourceLock`                          | `string`       | No       | Optional. Specify the type of resource lock.                                                                                                         |

## Outputs

| Name                      | Type   | Description                                          |
| :------------------------ | :----: | :--------------------------------------------------- |
| name                      | string | The name of the elastic pool.                          |
| resourceId                | string | The resource ID of the elastic pool.                   |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.
