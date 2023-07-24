# Private DNS Zones Module

This module deploys Microsoft.Network virtualNetworkLinks.
The module loops through an array or private DNS Zones and adds the vnet link.

## Description

This module performs the following

- Links the Private DNS Zone to an existing virtual network if specified.
- Enables auto-registration of virtual machine records if specified.

## Parameters

| Name                        | Type     | Required | Description                                                                                                    |
| :-------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------- |
| `name`                      | `string` | Yes      | The Private DNS Zone name.                                                                                             |
| `location`                  | `string` | Yes      | The geo-location where the resource lives.                                                                     |
| `virtualNetworkResourceIds` | `array`  | No       | Optional. Existing virtual network resource ID(s). Only required if enableVirtualNeworkLink equals true.       |
| `registrationEnabled`       | `bool`   | No       | Optional. Enable auto-registration of virtual machine records in the virtual network for the Private DNS zone. |


## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.