# Public IP Module

This module deploys a Microsoft.Network/publicIPAddresses resource.

## Details

- Creates `Microsoft.Network/publicIPAddresses` resource.
- Applies a `Microsoft.Insights/diagnosticSettings` to the resource if specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | Name of the Public IP resource.                                                                                         |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `dnsNameLabel`                          | `string` | No       | Optional. A name associated with Azure region. e.g example.australiasoutheast.cloudapp.azure.com.                       |
| `publicIPAllocationMethod`              | `string` | No       | Optional. The Public IP allocation method.                                                                              |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |

## Outputs

| Name         | Type     | Description                               |
| :----------- | :------: | :---------------------------------------- |
| `resourceId` | `string` | The ID of the Public IP resource.         |
| `name`       | `string` | The name of the Public IP resource.       |
| `ipAddress`  | `string` | The IP Address of the Public IP resource. |
| `dnsName`    | `string` | The DNS Label of the Public IP resource.  |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.