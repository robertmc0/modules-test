# Azure Databricks Module

Deploys Azure Databricks using the premium sku

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                          |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                                   |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                                           |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                             |
| `sku`                                   | `string` | No       | The sku of the resource                                                                                                                              |
| `publicNetworkAccess`                   | `string` | No       | Optional. Whether or not public endpoint access is allowed for this server. Only Disable if you wish to restrict to just private endpoints and VNET. |
| `enableNoPublicIp`                      | `bool`   | No       | Optional. Enable or disable public IP for the resource. Vnet injection requires public IP to be disabled.                                            |
| `managedResourceGroupId`                | `string` | Yes      | Id of the managed resource group                                                                                                                     |
| `customVirtualNetworkId`                | `string` | Yes      | Id of the virtual network for databricks to use                                                                                                      |
| `customPrivateSubnetName`               | `string` | Yes      | Name of the private subnet for databricks to use                                                                                                     |
| `customPublicSubnetName`                | `string` | Yes      | Name of the public subnet for databricks to use                                                                                                      |
| `requiredNsgRules`                      | `string` | No       | NSG rules to be applied to the custom subnets.  NoAzureDatabricksRules must be selected to use private endpoints                                     |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                 |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                     |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                       |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                            |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                    |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                              |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                         |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                                         |

## Outputs

| Name       | Type   | Description                                         |
| :--------- | :----: | :-------------------------------------------------- |
| name       | string | The name of the deployed databricks service.        |
| resourceId | string | The resource ID of the deployed databricks service. |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```