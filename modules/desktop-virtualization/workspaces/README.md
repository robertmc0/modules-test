# Microsoft.DesktopVirtualization workspaces Module

This module deploys Microsoft.DesktopVirtualization Workspaces

## Details

- Creates Microsoft.DesktopVirtualization workspaces resource.
- Applies diagnostic settings if specified.
- Applies a resource lock if specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                           |
| :-------------------------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                                                    |
| `friendlyName`                          | `string` | No       | Optional. Friendly name of Workspace.                                                                                                                                 |
| `workspaceDescription`                  | `string` | No       | Optional. Description for Workspace.                                                                                                                                  |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                                                            |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                              |
| `applicationGroupReferences`            | `array`  | Yes      | List of applicationGroup resource Ids.                                                                                                                                |
| `publicNetworkAccess`                   | `string` | No       | Optional. Enabled allows this resource to be accessed from both public and private networks, Disabled allows this resource to only be accessed via private endpoints. |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                                  |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                                      |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                                             |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                                     |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                                               |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                                          |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                                                          |

## Outputs

| Name         | Type     | Description                                |
| :----------- | :------: | :----------------------------------------- |
| `name`       | `string` | The name of the deployed workspace.        |
| `resourceId` | `string` | The resource ID of the deployed workspace. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.