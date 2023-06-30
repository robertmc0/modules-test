# Virtual Network Gateways Module

This module deploys Microsoft.Network virtualNetworkGateways.

## Description

This module performs the following

- Creates Microsoft.Network virtualNetworkGateways resource.
- Enables availability zones on public IP address if specified. This is required in some configuration scenarios.
- Optionally enables active-active mode and/or BGP.
- Applies diagnostic settings to all resources.
- Applies a lock to the virtual network gateway if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                         |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                  |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                          |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                            |
| `sku`                                   | `string` | Yes      | The sku of this virtual network gateway.                                                                                            |
| `gatewayType`                           | `string` | Yes      | The type of this virtual network gateway.                                                                                           |
| `vpnType`                               | `string` | No       | Optional. The type of this virtual network gateway.                                                                                 |
| `primaryPublicIpAddressName`            | `string` | Yes      | Name of the primary virtual network gateway public IP address.                                                                      |
| `availabilityZones`                     | `array`  | No       | Optional. A list of availability zones denoting the zone in which the virtual network gateway public IP address should be deployed. |
| `subnetResourceId`                      | `string` | Yes      | Resource ID of the virtual network gateway subnet.                                                                                  |
| `activeActive`                          | `bool`   | No       | Optional. Enable active-active mode.                                                                                                |
| `secondaryPublicIpAddressName`          | `string` | No       | Optional. Name of the secondary virtual network gateway public IP address. Only required when activeActive is set to true.          |
| `enableBgp`                             | `bool`   | No       | Optional. Enable BGP.                                                                                                               |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                    |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                      |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                           |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                   |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.             |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                        |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                        |

## Outputs

| Name                       | Type     | Description                                                                          |
| :------------------------- | :------: | :----------------------------------------------------------------------------------- |
| `name`                     | `string` | The name of the deployed virtual network gateway.                                    |
| `resourceId`               | `string` | The resource ID of the deployed virtual network gateway.                             |
| `primaryPublicIpName`      | `string` | The name of the deployed virtual network gateway primary public IP.                  |
| `primaryPublicIpAddress`   | `string` | The IP address of the deployed virtual network gateway primary public IP.            |
| `primaryPublicIpId`        | `string` | The resource ID of the deployed virtual network gateway primary public IP address.   |
| `secondaryPublicIpName`    | `string` | The name of the deployed virtual network gateway secondary public IP.                |
| `secondaryPublicIpAddress` | `string` | The IP address of the deployed virtual network gateway secondary public IP.          |
| `secondaryPublicIpId`      | `string` | The resource ID of the deployed virtual network gateway secondary public IP address. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.