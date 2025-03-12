# Automation Accounts Module

This module deploys Microsoft.Automation automationAccounts

## Details

This module performs the following

- Creates Microsoft.Automation automationAccounts resource.
- Imports modules into automation account if specified.
- Imports runbooks into automation account if specified.
- Creates a deployment update schedule if specified.
- Creates shared resource schedules and links to runbook if specified.
- Creates shared resource variables if specified.
- Applies diagnostic settings.
- Applies a lock to the bastion host if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `sku`                                   | `string` | No       | Optional. SKU name of the account.                                                                                      |
| `modules`                               | `array`  | No       | Optional. Modules to import into automation account.                                                                    |
| `variables`                             | `array`  | No       | Optional. Variables to import into automation account.                                                                  |
| `runbooks`                              | `array`  | No       | Optional. Runbooks to import into automation account.                                                                   |
| `schedules`                             | `array`  | No       | Optional. Schedules to import into automation account.                                                                  |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                     |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                          |
| `updateScheduleConfig`                  | `array`  | No       | Optional. Update schedule configuration.                                                                                |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |

## Outputs

| Name                        | Type     | Description                                         |
| :-------------------------- | :------: | :-------------------------------------------------- |
| `name`                      | `string` | The name of the deployed automation account.        |
| `resourceId`                | `string` | The resource ID of the deployed automation account. |
| `systemAssignedPrincipalId` | `string` | The principal ID of the system assigned identity.   |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.