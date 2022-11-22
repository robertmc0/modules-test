# VPN Sites Module

This module deploys Microsoft.Network vpnSites.

## Description

This module performs the following

- Creates Microsoft.Network vpnSites resource.
- Configures site links within VPN site.
- Applies a lock to the VPN site if the lock is specified.

## Parameters

| Name              | Type     | Required | Description                                                                  |
| :---------------- | :------: | :------: | :--------------------------------------------------------------------------- |
| `name`            | `string` | Yes      | The resource name.                                                           |
| `location`        | `string` | Yes      | The geo-location where the resource lives.                                   |
| `tags`            | `object` | No       | Optional. Resource tags.                                                     |
| `addressPrefixes` | `array`  | Yes      | A list of address blocks reserved for this virtual network in CIDR notation. |
| `deviceVendor`    | `string` | Yes      | Name of the device Vendor.                                                   |
| `virtualWanId`    | `string` | Yes      | Virtual WAN resource ID.                                                     |
| `vpnSiteLinks`    | `array`  | Yes      | List of all VPN site links.                                                  |
| `resourceLock`    | `string` | No       | Optional. Specify the type of resource lock.                                 |

## Outputs

| Name       | Type   | Description                               |
| :--------- | :----: | :---------------------------------------- |
| name       | string | The name of the deployed VPN site.        |
| resourceId | string | The resource ID of the deployed VPN site. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.