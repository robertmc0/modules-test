# Virtual Network Gateway Module

This module deploys Microsoft.Network/virtualNetworkGateways

## Details

{{Add detailed information about the module}}

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
| `enableBgp`                             | `bool`   | No       | Optional. Enable or disable BGP on the virtual network gateway.                                                                     |
| `customRoutePrefixes`                   | `array`  | No       | Optional. The additional routes to advertise to VPN clients connecting to the gateway.                                              |
| `vpnClientAddressPoolPrefixes`          | `array`  | No       | Optional. The address prefixes for VPN clients connecting to the gateway.                                                           |
| `vpnAuthenticationTypes`                | `array`  | No       | Optional. The VPN Authentication type(s) to be used.                                                                                |
| `vpnClientProtocols`                    | `array`  | No       | Optional. The VPN protocol(s) to be used.                                                                                           |
| `vpnClientRootCertificates`             | `array`  | No       | Optional. The VPN Client root certificates.                                                                                         |
| `vpnClientRevokedCertificates`          | `array`  | No       | Optional. VPN revoked certificates.                                                                                                 |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                    |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                |
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