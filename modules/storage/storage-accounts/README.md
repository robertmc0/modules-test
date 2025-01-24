# Storage Accounts

This module deploys Microsoft.StorageAccounts and child resources

## Details

This module performs the following

Creates Microsoft.StorageAccount resource.
Disables public access to storage account resource.
Creates blob containers if provided.
Creates file shares if provided.
Creates Storage queues if provided.
Creates Storage tables if provided.
Applies diagnostic settings.
Applies a lock to the storage account if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                                                               |
| :-------------------------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                                                                                        |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                                                                                                |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                                                                  |
| `sku`                                   | `string` | No       | Optional. The sku of the Storage Account.                                                                                                                                                                 |
| `kind`                                  | `string` | No       | Optional. The kind of Storage Account.                                                                                                                                                                    |
| `accessTier`                            | `string` | No       | Optional. Storage Account access tier, Hot for frequently accessed data or Cool for infrequently accessed data.                                                                                           |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                                                                                       |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                                                                                            |
| `publicNetworkAccess`                   | `string` | No       | Optional. Allow or disallow public network access to Storage Account.                                                                                                                                     |
| `allowSharedKeyAccess`                  | `bool`   | No       | Optional. Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key.                                                                             |
| `allowBlobPublicAccess`                 | `bool`   | No       | Optional. Allow or disallow public access to all blobs or containers in the storage account.                                                                                                              |
| `defaultToOAuthAuthentication`          | `bool`   | No       | Optional. Indicates whether the default authentication is OAuth (AD Authentication) or not.                                                                                                               |
| `deleteRetentionPolicy`                 | `int`    | No       | Optional. Amount of days the soft deleted data is stored and available for recovery.                                                                                                                      |
| `enableHierarchicalNamespace`           | `bool`   | No       | Optional. If true, enables Hierarchical Namespace for the Storage Account.                                                                                                                                |
| `requireInfrastructureEncryption`       | `bool`   | No       | Optional. A boolean indicating whether or not the service applies a secondary layer of encryption with platform managed keys for data at rest. For security reasons, it is recommended to set it to true. |
| `containers`                            | `array`  | No       | Optional. Containers to create in the Storage Account.                                                                                                                                                    |
| `fileShares`                            | `array`  | No       | Optional. Files shares to create in the Storage Account.                                                                                                                                                  |
| `queues`                                | `array`  | No       | Optional. Queue to create in the Storage Account.                                                                                                                                                         |
| `tables`                                | `array`  | No       | Optional. Tables to create in the Storage Account.                                                                                                                                                        |
| `networkAcls`                           | `object` | No       | Optional. Rule definitions governing the Storage network access.                                                                                                                                          |
| `largeFileSharesState`                  | `string` | No       | Optional. Allow large file shares if set to Enabled. It cannot be disabled once it is enabled.                                                                                                            |
| `managementPolicies`                    | `array`  | No       | Optional. Lifecycle management policies.                                                                                                                                                                  |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                                                                                              |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                                                                      |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                                                                          |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                                                                      |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                                                                                 |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                                                                         |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                                                                                   |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                                                                              |
| `enablechangeFeed`                      | `bool`   | No       | Optional.  If true, enable change feed.                                                                                                                                                                   |
| `changeFeedRetentionPolicy`             | `int`    | No       | Optional. Amount of days the change feed data is stored and available for recovery.                                                                                                                       |
| `enableblobVersioning`                  | `bool`   | No       | Optional.  If true, enable versioning for blobs.                                                                                                                                                          |
| `enablecontainerDeleteRetentionPolicy`  | `bool`   | No       | Optional.  If true, enable container delete retention policy.                                                                                                                                             |
| `containerDeleteRetentionPolicy`        | `int`    | No       | Optional. Amount of days the deleted container is available for recovery.                                                                                                                                 |
| `enablerestorePolicy`                   | `bool`   | No       | Optional.  If true, enable point-in-time restore for containers policy.                                                                                                                                   |
| `directoryServiceOptions`               | `string` | No       | Optional. Indicates the directory service used.                                                                                                                                                           |
| `activeDirectoryProperties`             | `object` | No       | Optional. Domain name for your on-premises AD. Required if directoryServiceOptions are AD, optional if they are AADKERB.                                                                                  |

## Outputs

| Name                        | Type     | Description                                                |
| :-------------------------- | :------: | :--------------------------------------------------------- |
| `name`                      | `string` | The name of the deployed storage account.                  |
| `resourceId`                | `string` | The resource ID of the deployed storage account.           |
| `systemAssignedPrincipalId` | `string` | The principal ID for the system-assigned managed identity. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.