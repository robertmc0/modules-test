# PostgreSQL flexibleServers

Deploy Azure PostgreSQL Flexible Servers

## Description

This module performs the following

Creates Microsoft.DBforPostgreSQL/flexibleServers resource

## Parameters

| Name                         | Type           | Required | Description                                                                                                                       |
| :--------------------------- | :------------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------- |
| `name`                       | `string`       | Yes      | Required. Name of your Azure PostgreSQL Flexible Server                                                                           |
| `location`                   | `string`       | No       | Optional. Location for all resources.                                                                                             |
| `tags`                       | `object`       | No       | Optional. Tags of the resource.                                                                                                   |
| `skuName`                    | `string`       | Yes      | The name of the sku, typically, tier + family + cores, e.g. Standard_D4s_v3.                                                      |
| `skuTier`                    | `string`       | Yes      | The tier of the particular SKU, e.g. Burstable.                                                                                   |
| `administratorLogin`         | `string`       | Yes      | The administrators login name of a server. Can only be specified when the server is being created (and is required for creation). |
| `administratorLoginPassword` | `secureString` | Yes      | The administrator login password (required for server creation).                                                                  |
| `backupRetentionDays`        | `int`          | Yes      | Backup retention days for the server.                                                                                             |
| `geoRedundantBackup`         | `string`       | No       | A value indicating whether Geo-Redundant backup is enabled on the server.                                                         |
| `createMode`                 | `string`       | No       | The mode to create a new PostgreSQL server.                                                                                       |
| `highAvailabilityMode`       | `string`       | No       | The HA mode for the server.                                                                                                       |
| `standbyAvailabilityZone`    | `string`       | No       | availability zone information of the standby.                                                                                     |
| `customWindow`               | `string`       | No       | indicates whether custom window is enabled or disabled.                                                                           |
| `dayOfWeek`                  | `int`          | No       | day of week for maintenance window                                                                                                |
| `startHour`                  | `int`          | No       | start hour for maintenance window                                                                                                 |
| `startMinute`                | `int`          | No       | start minute for maintenance window                                                                                               |
| `storageSizeGB`              | `int`          | Yes      | Max storage allowed for a server.                                                                                                 |
| `version`                    | `string`       | Yes      | The version of a server.                                                                                                          |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

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
    name: 'testpostgres'
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
