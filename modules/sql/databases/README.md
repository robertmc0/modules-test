# Sql Server Database

This module deploys Microsoft.Sql.Server databases

## Description

This module performs the following

- Creates SQL database against an existing SQL Server.
- Configures short term period.
- Applies diagnostic settings if specified.
- Applies a lock to the sql database if specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `sqlServerName`                         | `string` | Yes      | Name of existing Azure SQL Server.                                                                                                                         |
| `databaseName`                          | `string` | Yes      | Name of Database to create.                                                                                                                                |
| `location`                              | `string` | Yes      | Location of resource.                                                                                                                                      |
| `createMode`                            | `string` | No       | Optional. Specifies the mode of database creation.                                                                                                         |
| `skuType`                               | `string` | Yes      | A predefined set of SkuTypes. Currently template not configured to support Hyper-Scale or Business Critical.                                               |
| `skuCapacity`                           | `int`    | Yes      | If DTU model, define amount of DTU. If vCore model, define number of vCores (max for serverless).                                                          |
| `skuMinCapacity`                        | `string` | No       | Optional. Min vCore allocation. Applicable for vCore Serverless model only. Requires string to handle decimals.                                            |
| `maxDbSize`                             | `int`    | Yes      | Maximum database size in bytes for allocation.                                                                                                             |
| `autoPauseDelay`                        | `int`    | No       | Optional. Minutes before Auto Pause. Applicable for vCore Serverless model only.                                                                           |
| `retentionPeriod`                       | `int`    | No       | Optional. Defines the short term retention period.  Maximum of 35 days.                                                                                    |
| `databaseCollation`                     | `string` | No       | Optional. The SQL database Collation.                                                                                                                      |
| `zoneRedundant`                         | `bool`   | No       | Optional. Whether the databases are zone redundant. Only supported in some regions.                                                                        |
| `licenseType`                           | `string` | No       | Optional. For Azure Hybrid Benefit, use BasePrice.                                                                                                         |
| `readScaleOut`                          | `string` | No       | Optional. Allow ReadOnly from secondary endpoints.                                                                                                         |
| `requestedBackupStorageRedundancy`      | `string` | No       | Optional. Set location of backups, geo, local or zone.                                                                                                     |
| `elasticPoolId`                         | `string` | No       | Optional. Elastic Pool ID.                                                                                                                                 |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                   |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of lock.                                                                                                                        |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                       |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Resource ID of the diagnostic log analytics workspace.                                                                                           |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.   |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                             |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Resource ID of the diagnostic storage account.                                                                                                   |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                           |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                       |

## Outputs

| Name       | Type   | Description                          |
| :--------- | :----: | :----------------------------------- |
| name       | string | The name of the sql database.        |
| resourceId | string | The resource ID of the sql database. |

## Examples

### Example 1

```bicep

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: 'example-law-${serviceShort}-01'
  location: location
}

// Create a diagnostics setting object to use for all resources
var diagSettings = {
  name: 'diag-log'
  workspaceId: logAnalyticsWorkspace.id
  storageAccountId: ''
  eventHubAuthorizationRuleId: ''
  eventHubName: ''
  enableLogs: true
  enableMetrics: false
  retentionPolicy: {
    days: 0
    enabled: false
  }
}

module azureSqlDatabase 'br/ArincoModules:sql.servers.databases:0.1.1' = {
  name: '${uniqueString(deployment().name, 'AustraliaEast')}-sqldatabase'
  params: {
    sqlServerName: 'example-dev-sql'
    databaseName: 'sql-prd-shortname-workloadname'
    skuType: 'Standard'
    skuCapacity: 10
    diagSettings: diagSettings
    maxDbSize: 10737418240
  }
}
```