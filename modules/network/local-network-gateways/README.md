# Local Network Gateway Module

This module deploys Microsoft.Network localNetworkGateways

## Description

This module performs the following

- Creates Microsoft.Network localNetworkGateways resource.
- Applies a lock to the network watcher if the lock is specified.

## Parameters

| Name              | Type     | Required | Description                                                                  |
| :---------------- | :------: | :------: | :--------------------------------------------------------------------------- |
| `name`            | `string` | Yes      | The resource name.                                                           |
| `location`        | `string` | Yes      | The geo-location where the resource lives.                                   |
| `tags`            | `object` | No       | Optional. Resource tags.                                                     |
| `bgpSettings`     | `object` | No       | Optional. Local network gateway BGP speaker settings.                        |
| `addressPrefixes` | `array`  | No       | A list of address blocks reserved for this virtual network in CIDR notation. |
| `endpointType`    | `string` | Yes      | The endpoint type of the local network gateway.                              |
| `endpoint`        | `string` | Yes      | The endpoint of the local network gateway. Either FQDN or IpAddress.         |
| `resourceLock`    | `string` | No       | Optional. Specify the type of resource lock.                                 |

## Outputs

| Name         | Type     | Description                                            |
| :----------- | :------: | :----------------------------------------------------- |
| `name`       | `string` | The name of the deployed local network gateway.        |
| `resourceId` | `string` | The resource ID of the deployed local network gateway. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.