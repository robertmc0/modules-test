# Bastion Host Module

This module deploys Microsoft.Network bastionHosts

## Details

This module performs the following

- Creates Microsoft.Network bastionHosts resource.
- Applies diagnostic settings.
- Applies a lock to the bastion host if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `sku`                                   | `string` | No       | Optional. The sku of this Bastion Host.                                                                                 |
| `disableCopyPaste`                      | `bool`   | No       | Optional. Enable/Disable Copy/Paste feature of the Bastion Host resource.                                               |
| `enableFileCopy`                        | `bool`   | No       | Optional. Enable/Disable File Copy feature of the Bastion Host resource..                                               |
| `dnsName`                               | `string` | No       | Optional. FQDN for the endpoint on which bastion host is accessible.                                                    |
| `enableIpConnect`                       | `bool`   | No       | Optional. Enable/Disable IP Connect feature of the Bastion Host resource.                                               |
| `enableShareableLink`                   | `bool`   | No       | Optional. Enable/Disable Shareable Link of the Bastion Host resource.                                                   |
| `enableTunneling`                       | `bool`   | No       | Optional. Enable/Disable Tunneling feature of the Bastion Host resource.                                                |
| `scaleUnits`                            | `int`    | No       | Optional. The scale units for the Bastion Host resource.                                                                |
| `publicIpAddressName`                   | `string` | Yes      | Name of the Bastion Host public IP address.                                                                             |
| `subnetResourceId`                      | `string` | Yes      | Resource ID of the bastion subnet.                                                                                      |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |

## Outputs

| Name         | Type     | Description                                   |
| :----------- | :------: | :-------------------------------------------- |
| `name`       | `string` | The name of the deployed bastion host.        |
| `resourceId` | `string` | The resource ID of the deployed bastion host. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.