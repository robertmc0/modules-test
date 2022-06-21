# Storage Accounts

This module deploys Microsoft.StorageAccounts and child resources

## Description

This module performs the following

Creates Microsoft.StorageAccount resource.
Creates blob containers if provided.
Creates file shares if provided.
Creates Storage queues if provided.
Creates Storage tables if provided.
Applies diagnostic settings.
Applys a lock to the storage account if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                                                               |
| :-------------------------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | Storage account name.                                                                                                                                                                                     |
| `location`                              | `string` | Yes      | Storage account location.                                                                                                                                                                                 |
| `sku`                                   | `string` | No       | Storage account sku.                                                                                                                                                                                      |
| `kind`                                  | `string` | No       | Storage account kind.                                                                                                                                                                                     |
| `accessTier`                            | `string` | No       | Storage account access tier, Hot for frequently accessed data or Cool for infreqently accessed data.                                                                                                      |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                                                                                       |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                                                                                            |
| `publicNetworkAccess`                   | `string` | No       | Allow or disallow public network access to Storage Account.                                                                                                                                               |
| `deleteRetentionPolicy`                 | `int`    | No       | Amount of days the soft deleted data is stored and available for recovery.                                                                                                                                |
| `enableHierarchicalNamespace`           | `bool`   | No       | Optional. If true, enables Hierarchical Namespace for the storage account                                                                                                                                 |
| `requireInfrastructureEncryption`       | `bool`   | No       | Optional. A boolean indicating whether or not the service applies a secondary layer of encryption with platform managed keys for data at rest. For security reasons, it is recommended to set it to true. |
| `containers`                            | `array`  | No       | Containers to create in the storage account.                                                                                                                                                              |
| `fileShares`                            | `array`  | No       | Files shares to create in the storage account.                                                                                                                                                            |
| `queues`                                | `array`  | No       | Queue to create in the storage account.                                                                                                                                                                   |
| `tables`                                | `array`  | No       | Optional. Tables to create.                                                                                                                                                                               |
| `networkAcls`                           | `object` | No       | Rule definitions governing the Storage network access.                                                                                                                                                    |
| `resourcelock`                          | `string` | No       | Specify the type of resource lock.                                                                                                                                                                        |
| `enableDiagnostics`                     | `bool`   | No       | Enable diagnostic logs.                                                                                                                                                                                   |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                                                                            |
| `diagnosticStorageAccountId`            | `string` | No       | Storage account resource id. Only required if enableDiagnostics is set to true.                                                                                                                           |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                                                                                   |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                                                                                             |
| `diagnosticEventHubName`                | `string` | No       | Event hub name. Only required if enableDiagnostics is set to true.                                                                                                                                        |

## Outputs

| Name       | Type   | Description                                     |
| :--------- | :----: | :---------------------------------------------- |
| name       | string | The name of the deployed storage account        |
| resourceId | string | The resource ID of the deployed storage account |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.