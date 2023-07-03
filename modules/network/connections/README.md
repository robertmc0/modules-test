# Connections Module

This module deploys Microsoft.Network connections

## Description

This module performs the following

- Creates Microsoft.Network connections resource.
- Optionally enables BGP for the connection.
- Optionally enables policy-based traffic selectors for the connection.
- Allows for custom IPsec policies to be specified.
- Allows for custom NAT rules to be specified.
- Optionally enables a resource lock on the resource.

## Parameters

| Name                             | Type           | Required | Description                                                              |
| :------------------------------- | :------------: | :------: | :----------------------------------------------------------------------- |
| `name`                           | `string`       | Yes      | The resource name.                                                       |
| `location`                       | `string`       | Yes      | The geo-location where the resource lives.                               |
| `tags`                           | `object`       | No       | Optional. Resource tags.                                                 |
| `connectionType`                 | `string`       | Yes      | Gateway connection type.                                                 |
| `virtualNetworkGatewayId`        | `string`       | Yes      | The resource ID of the virtual network gateway.                          |
| `enableBgp`                      | `bool`         | No       | Optional. Enable BGP for this connection.                                |
| `connectionProtocol`             | `string`       | Yes      | Connection protocol used for this connection.                            |
| `sharedKey`                      | `securestring` | Yes      | The IPSec shared key (PSK).                                              |
| `ipsecPolicies`                  | `array`        | No       | Optional. IPsec policies to be considered by this connection.            |
| `usePolicyBasedTrafficSelectors` | `bool`         | No       | Optional. Use policy-based traffic selectors for this connection.        |
| `dpdTimeoutSeconds`              | `int`          | No       | Optional. The dead peer detection timeout of this connection in seconds. |
| `connectionMode`                 | `string`       | No       | Optional. The connection mode used for this connection.                  |
| `localNetworkGatewayId`          | `string`       | Yes      | The resource ID of the local network gateway.                            |
| `ingressNatRules`                | `array`        | No       | Optional. Ingress NAT rules for this connection.                         |
| `egressNatRules`                 | `array`        | No       | Optional. Egress NAT rules for this connection.                          |
| `resourceLock`                   | `string`       | No       | Optional. Specify the type of resource lock.                             |

## Outputs

| Name         | Type     | Description                                 |
| :----------- | :------: | :------------------------------------------ |
| `name`       | `string` | The name of the deployed connection.        |
| `resourceId` | `string` | The resource ID of the deployed connection. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.