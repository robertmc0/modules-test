# PostgreSQL flexibleServers

Deploy Azure PostgreSQL Flexible Servers

## Description

This module performs the following

Creates Microsoft.DBforPostgreSQL/flexibleServers resource

## Parameters

| Name                                    | Type           | Required | Description                                                                                                                                                                                                                               |
| :-------------------------------------- | :------------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string`       | Yes      | Name of your Azure PostgreSQL Flexible Server - if error ServerGroupDropping is received during deployment then the server name is not available and must be changed to one that is. This can be checked by running a console deployment. |
| `location`                              | `string`       | Yes      | Location for all resources.                                                                                                                                                                                                               |
| `tags`                                  | `object`       | No       | Optional. Resource tags.                                                                                                                                                                                                                  |
| `skuName`                               | `string`       | Yes      | The name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3.                                                                                                                                                              |
| `skuTier`                               | `string`       | Yes      | The tier of the particular SKU, e.g. Burstable.                                                                                                                                                                                           |
| `administratorLogin`                    | `string`       | Yes      | The administrators login name of a server. Can only be specified when the server is being created (and is required for creation).                                                                                                         |
| `administratorLoginPassword`            | `secureString` | Yes      | The administrator login password (required for server creation).                                                                                                                                                                          |
| `backupRetentionDays`                   | `int`          | Yes      | Backup retention days for the server.                                                                                                                                                                                                     |
| `geoRedundantBackup`                    | `string`       | No       | A value indicating whether Geo-Redundant backup is enabled on the server.                                                                                                                                                                 |
| `createMode`                            | `string`       | No       | The mode to create a new PostgreSQL server.                                                                                                                                                                                               |
| `highAvailabilityMode`                  | `string`       | No       | The HA mode for the server.                                                                                                                                                                                                               |
| `standbyAvailabilityZone`               | `string`       | No       | Availability zone information of the standby.                                                                                                                                                                                             |
| `privateDnsZoneArmResourceId`           | `string`       | No       | Private dns zone arm resource id in which to create the Private DNS zone for this PostgreSQL server.                                                                                                                                      |
| `delegatedSubnetResourceId`             | `string`       | No       | Delegated subnet arm resource id. Subnet must be dedicated to Azure PostgreSQL servers.                                                                                                                                                   |
| `customWindow`                          | `string`       | No       | Indicates whether custom maintenance window is enabled or disabled.                                                                                                                                                                       |
| `dayOfWeek`                             | `int`          | No       | Day of week for maintenance window.                                                                                                                                                                                                       |
| `startHour`                             | `int`          | No       | Start hour for maintenance window.                                                                                                                                                                                                        |
| `startMinute`                           | `int`          | No       | Start minute for maintenance window.                                                                                                                                                                                                      |
| `storageSizeGB`                         | `int`          | Yes      | Max storage allowed for a server.                                                                                                                                                                                                         |
| `version`                               | `string`       | Yes      | The version of a server.                                                                                                                                                                                                                  |
| `enableDiagnostics`                     | `bool`         | No       | Optional. Enable diagnostic logging.                                                                                                                                                                                                      |
| `diagnosticLogCategoryGroupsToEnable`   | `array`        | No       | Optional. The name of log category groups that will be streamed.                                                                                                                                                                          |
| `diagnosticMetricsToEnable`             | `array`        | No       | Optional. The name of metrics that will be streamed.                                                                                                                                                                                      |
| `diagnosticLogsRetentionInDays`         | `int`          | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                                                                                                            |
| `diagnosticStorageAccountId`            | `string`       | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                                                                                                                 |
| `diagnosticLogAnalyticsWorkspaceId`     | `string`       | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                                                                                                         |
| `diagnosticEventHubAuthorizationRuleId` | `string`       | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                                                                                                                   |
| `diagnosticEventHubName`                | `string`       | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                                                                                                              |
| `resourcelock`                          | `string`       | No       | Optional. Specify the type of resource lock.                                                                                                                                                                                              |

## Outputs

| Name       | Type   | Description                                                 |
| :--------- | :----: | :---------------------------------------------------------- |
| name       | string | The name of the deployed PostgreSQL Flexible Server.        |
| resourceId | string | The resource ID of the deployed PostgreSQL Flexible Server. |

## Examples

### Example 1

```bicep
param location string = 'australiaeast'

@secure()
param psqlPassword string = uniqueString(newGuid())

module postgres '../main.bicep' = {
  name: 'deploy_postgres'
  params: {
    location: location
    name: 'test-postgres'
    administratorLogin: 'psqladmin'
    administratorLoginPassword: psqlPassword
    backupRetentionDays: 30
    skuName: 'Standard_D4s_v3'
    skuTier: 'GeneralPurpose'
    storageSizeGB: 64
    version: '13'
  }
}
```