# Azure Machine Learning Workspace Module

Deploys Azure Machine Learning Workspace

## Details

- Creates Microsoft.MachineLearningServices workspaces resource.
- Applies diagnostic settings.
- Applies a lock to the machine learning workspace if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                             |
| :-------------------------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                      |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                |
| `storageAccountResourceId`              | `string` | Yes      | Required. ResourceId of the storage account associated with this workspace. This cannot be changed once the workspace has been created. |
| `keyVaultResourceId`                    | `string` | Yes      | Required. ResourceId of the key vault associated with this workspace. This cannot be changed once the workspace has been created.       |
| `applicationInsightsResourceId`         | `string` | Yes      | Required. ResourceId of the application insights associated with this workspace.                                                        |
| `containerRegistryResourceId`           | `string` | No       | Optional. ResourceId of the container registry associated with this workspace.                                                          |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                     |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                          |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                    |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                 |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                            |

## Outputs

| Name         | Type     | Description                                                 |
| :----------- | :------: | :---------------------------------------------------------- |
| `name`       | `string` | The name of the deployed machine learning workspace.        |
| `resourceId` | `string` | The resource ID of the deployed machine learning workspace. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.