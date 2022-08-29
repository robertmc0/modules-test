# Recovery Services Vaults Module

This module deploys Microsoft.RecoveryServices vaults

## Description

This module performs the following

- Creates Microsoft.RecoveryServices vaults resource.
- Configures storage replication type.
- Configures backup policies if specified.
- Enable cross region restore if specified.
- Adds existing Azure virtual machines to backup policy if specified.
- Applies diagnostic settings.
- Applies a lock to the bastion host if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `sku`                                   | `string` | No       | Optional. The sku of the recovery services vault.                                                                       |
| `storageType`                           | `string` | No       | Optional. Storage replication type of the recovery services vault.                                                      |
| `enablecrossRegionRestore`              | `bool`   | No       | Optional. Enable cross region restore.                                                                                  |
| `backupPolicies`                        | `array`  | No       | Optional. Backup policies.                                                                                              |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                     |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                          |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.          |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `addVmToBackupPolicy`                   | `array`  | No       | Optional. Add existing Azure virtual machine(s) to backup policy.                                                       |

## Outputs

| Name       | Type   | Description                                              |
| :--------- | :----: | :------------------------------------------------------- |
| name       | string | The name of the deployed recovery services vault.        |
| resourceId | string | The resource ID of the deployed recovery services vault. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.