# Databricks Module

This module deploys Microsoft.Databricks

## Details

{{ Add detailed description for the module. }}

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                          |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                                   |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                                           |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                             |
| `sku`                                   | `string` | No       | Optional. The sku of the resource.                                                                                                                   |
| `publicNetworkAccess`                   | `string` | No       | Optional. Whether or not public endpoint access is allowed for this server. Only Disable if you wish to restrict to just private endpoints and VNET. |
| `enableNoPublicIp`                      | `bool`   | No       | Optional. Enable or disable public IP for the resource. Vnet injection requires public IP to be disabled.                                            |
| `managedResourceGroupId`                | `string` | Yes      | Managed resource group resource id.                                                                                                                  |
| `customVirtualNetworkId`                | `string` | Yes      | Databricks virtual network resource id.                                                                                                              |
| `customPrivateSubnetName`               | `string` | Yes      | Private subnet name for databricks.                                                                                                                  |
| `customPublicSubnetName`                | `string` | Yes      | Public subnet name for databricks.                                                                                                                   |
| `requiredNsgRules`                      | `string` | No       | Optional. NSG rules to be applied to the custom subnets.  NoAzureDatabricksRules must be selected to use private endpoints.                          |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                 |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                     |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                            |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                    |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                              |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                         |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                                         |

## Outputs

| Name         | Type     | Description                                         |
| :----------- | :------: | :-------------------------------------------------- |
| `name`       | `string` | The name of the deployed databricks service.        |
| `resourceId` | `string` | The resource ID of the deployed databricks service. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.