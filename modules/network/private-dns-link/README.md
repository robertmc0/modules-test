# Private DNS Zones VNET Link Module

This module deploys Microsoft.Network virtualNetworkLinks.

## Details

This module performs the following

- Links the Private DNS Zone to an existing virtual network if specified.
- Enables auto-registration of virtual machine records if specified.

## Parameters

| Name                       | Type     | Required | Description                                                   |
| :------------------------- | :------: | :------: | :------------------------------------------------------------ |
| `virtualNetworkResourceId` | `string` | Yes      | Optional. Existing virtual network resource ID(s).            |
| `registrationEnabled`      | `bool`   | No       | Optional. The Private DNS Zone name.                          |
| `name`                     | `string` | Yes      | The resource name.                                            |
| `location`                 | `string` | Yes      | Optional. The location where the Private DNS Zone is deployed |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.