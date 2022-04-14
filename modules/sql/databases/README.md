# Sql Server Database

This module deploys Microsoft.Sql.Server databases

## Parameters

| Name                               | Type     | Required | Description                                                                                                  |
| :--------------------------------- | :------: | :------: | :----------------------------------------------------------------------------------------------------------- |
| `sqlServerName`                    | `string` | Yes      | Name of existing Azure SQL Server                                                                            |
| `databaseName`                     | `string` | Yes      | Name of Database to create                                                                                   |
| `location`                         | `string` | No       | Location of resource                                                                                         |
| `skuType`                          | `string` | Yes      | A predefined set of SkuTypes. Currently template not configured to support Hyper-Scale or Business Critical. |
| `skuCapacity`                      | `int`    | Yes      | If DTU model, define amount of DTU. If vCore model, define number of vCores (max for serverless)             |
| `skuMinCapacity`                   | `string` | No       | Min vCore allocation. Applicable for vCore Serverless model only. Feed as string to handle floats.           |
| `maxDbSize`                        | `int`    | Yes      | Maximum database size in bytes for allocation.                                                               |
| `autoPauseDelay`                   | `int`    | No       | Minutes before Auto Pause. Applicable for vCore Serverless model only                                        |
| `retentionPeriod`                  | `int`    | No       | Defines the short term retention period.  Maximum of 35 days.                                                |
| `databaseCollation`                | `string` | No       | The SQL database Collation.                                                                                  |
| `zoneRedundant`                    | `bool`   | No       | Whether the databases are zone redundant. Only supported in some regions.                                    |
| `licenseType`                      | `string` | No       | For Azure Hybrid Benefit, use BasePrice                                                                      |
| `readScaleOut`                     | `string` | No       | Allow ReadOnly from secondary endpoints                                                                      |
| `requestedBackupStorageRedundancy` | `string` | No       | Set location of backups, geo, local or zone                                                                  |
| `tags`                             | `object` | No       | Object containing resource tags.                                                                             |
| `enableResourceLock`               | `bool`   | No       | Enable a Can Not Delete Resource Lock.  Useful for production workloads.                                     |
| `diagSettings`                     | `object` | No       | Object containing diagnostics settings. If not provided diagnostics will not be set.                         |

## Outputs

| Name | Type   | Description                         |
| :--- | :----: | :---------------------------------- |
| name | string | The name of the sql database        |
| id   | string | The resource ID of the sql database |

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