# Virtual Network VPN Gateways Module

This module deploys Microsoft.Network vpnGateways.

## Description

This module performs the following

- Creates Microsoft.Network vpnGateways resource.
- Enables the configuration of custom BGP settings.
- Enablement of BGP routes translation for NAT.
- Enable Routing Preference property for the Public IP Interface of the VpnGateway.
- Applies diagnostic settings.
- Applies a lock to the vpn gateway if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `bgpSettings`                           | `object` | No       | Optional. Local network gateway's BGP speaker settings.                                                                 |
| `enableBgpRouteTranslationForNat`       | `bool`   | No       | Optional. Enable BGP routes translation for NAT on this VpnGateway.                                                     |
| `isRoutingPreferenceInternet`           | `bool`   | No       | Optional. Enable Routing Preference property for the Public IP Interface of the VpnGateway.                             |
| `virtualHubResourceId`                  | `string` | No       | Optional. Virtual Hub resource ID.                                                                                      |
| `vpnGatewayScaleUnit`                   | `int`    | No       | Optional. The scale unit for this vpn gateway.                                                                          |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.          |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |

## Outputs

| Name       | Type   | Description                                  |
| :--------- | :----: | :------------------------------------------- |
| name       | string | The name of the deployed vpn gateway.        |
| resourceId | string | The resource ID of the deployed vpn gateway. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.