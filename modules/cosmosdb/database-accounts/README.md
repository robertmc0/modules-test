# COSMOS DB Account Module

This module deploys COSMOS DB Account and container resources.

## Description

This module performs the following

- Creates Microsoft.DocumentDB/databaseAccounts resource.
- Creates Microsoft.DocumentDB/databaseAccounts/sqlDatabases resource.
- Creates one to many of Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers resource.
- Applies permissions to the Cosmos DB account.
- Applies a lock to the Cosmos DB account if the lock is specified.

### Scale settings

The module provides options to configure scale settings at either the database or container level. By default each container uses autoscale and has a maximum throughput of 1000 RUs, which is the minimum allowed value.

- Use the **databaseScalingOptions** parameter to set a dedicated scale limit at the database level.
- Use the **defaultContainerScaleSettings** parameter to configure a default scale setting for each container.
- Use the **containerConfigurations[].options** property to configure a specific scale setting for a container.

Refer to the examples for further details.

### Accessing Cosmos DB

Use https://cosmos.azure.com/?feature.enableAadDataPlane=true to acccess COSMOS DB. This module does not permit access to COSMOS DB via the portal.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                                       |
| :-------------------------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                                                                        |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                                          |
| `name`                                  | `string` | Yes      | The name of the COSMOS DB account.                                                                                                                                                |
| `databaseName`                          | `string` | Yes      | The database to create in the COSMOS DB account.                                                                                                                                  |
| `locations`                             | `array`  | Yes      | An array that contains the georeplication locations enabled for the Cosmos DB account.                                                                                            |
| `containerConfigurations`               | `array`  | Yes      | Container configurations to apply to the COSMOS DB account.                                                                                                                       |
| `accountAccess`                         | `object` | Yes      | Access permissions to apply to the COSMOS DB account.                                                                                                                             |
| `virtualNetworkSubnetId`                | `string` | No       | Optional. The full resource ID of a subnet in a virtual network to deploy the COSMOS DB account in.                                                                               |
| `publicNetworkAccess`                   | `string` | No       | Optional. Indicates whether to allow public network access. Defaults to Disabled.                                                                                                 |
| `disableLocalAuth`                      | `bool`   | No       | Optional. Indicates whether to disable local authentication with access keys. Defaults to true.                                                                                   |
| `disableKeyBasedMetadataWriteAccess`    | `bool`   | No       | Optional. Disable write operations on metadata resources (databases, containers, throughput) via account keys. Defaults to true.                                                  |
| `consistencyPolicy`                     | `object` | No       | Optional. The consistency policy for the Cosmos DB account. Defaults to Session consistency.                                                                                      |
| `enableMultipleWriteLocations`          | `bool`   | No       | Optional. Indicates whether multiple write locations is enabled.                                                                                                                  |
| `enableAutomaticFailover`               | `bool`   | No       | Optional. Indicates whether automatic failover is enabled.                                                                                                                        |
| `enableAnalyticalStorage`               | `bool`   | No       | Optional. Indicates whether to enable storage analytics.                                                                                                                          |
| `analyticalStorageConfiguration`        | `object` | No       | Optional. Analytical storage specific properties.                                                                                                                                 |
| `capacity`                              | `object` | No       | Optional. Total capacity limit for the Cosmos DB account.                                                                                                                         |
| `defaultContainerScaleSettings`         | `object` | No       | Optional. The default scale settings to apply to each container, when not using dedicated (database level) scale settings. Defaults to autoscale with max throughput of 1000 RUs. |
| `databaseScalingOptions`                | `object` | No       | Optional. The dedicated (database level) scale settings to apply. When not provided, scale settings are configured on each container.                                             |
| `allowedIpAddressOrRanges`              | `array`  | No       | Optional. List of IP rules to apply to the Cosmos DB account.                                                                                                                     |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of lock.                                                                                                                                               |
| `diagnosticLogCategoryToEnable`         | `array`  | No       | Optional. The name of log category that will be streamed.                                                                                                                         |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                                              |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                                              |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Resource ID of the diagnostic log analytics workspace.                                                                                                                  |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.                        |
| `diagnosticEventHubName`                | `string` | No       | Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.                          |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                                                    |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Resource ID of the diagnostic storage account.                                                                                                                          |

## Outputs

| Name       | Type   | Description                               |
| :--------- | :----: | :---------------------------------------- |
| name       | string | The name of the COSMOS DB account.        |
| resourceId | string | The resource ID of the COSMOS DB account. |

## Examples

Please see the following files for examples.

- [Bicep Test - Minimum Parameters](test/main.test.bicep)
- [Bicep Test - COSMOS DB with dedicated scale settings](test/main.test.dedicated.bicep)
- [Bicep Test - COSMOS DB with specific container scale and security settings](test/main.test.advanced.bicep)