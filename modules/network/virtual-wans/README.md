# Virtual Wans Module

This module deploys Microsoft.Network virtualWans.

## Description

This module performs the following

- Creates Microsoft.Network virtualWans resource.
- Creates Microsoft.Network virtualHubs resource. Allowing multiple virtual hubs to be created.
- Enable or disable branch to branch traffic.
- Enable or disable vnet to vnet traffic.
- Enable or disable vpn encryption.
- Applies a lock to the virtual wan if the lock is specified.

## Parameters

| Name                         | Type     | Required | Description                                     |
| :--------------------------- | :------: | :------: | :---------------------------------------------- |
| `name`                       | `string` | Yes      | The resource name.                              |
| `location`                   | `string` | Yes      | The geo-location where the resource lives.      |
| `tags`                       | `object` | No       | Optional. Resource tags.                        |
| `allowBranchToBranchTraffic` | `bool`   | No       | Optional. Allow branch to branch traffic.       |
| `allowVnetToVnetTraffic`     | `bool`   | No       | Optional. Allow Vnet to Vnet traffic.           |
| `disableVpnEncryption`       | `bool`   | No       | Optional. Vpn encryption to be disabled or not. |
| `type`                       | `string` | No       | Optional. The type of the VirtualWAN.           |
| `virtualHubs`                | `array`  | No       | Optional. Virtual Hub configuration.            |
| `resourceLock`               | `string` | No       | Optional. Specify the type of resource lock.    |

## Outputs

| Name       | Type   | Description                                         |
| :--------- | :----: | :-------------------------------------------------- |
| name       | string | The name of the deployed virtual wan.               |
| resourceId | string | The resource ID of the deployed virtual wan.        |
| hubs       | array  | List of virtual hubs associated to the virtual wan. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.