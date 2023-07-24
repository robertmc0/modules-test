# Private DNS Zones VNET Link Module

This module deploys Microsoft.Network virtualNetworkLinks.

## Details

This module performs the following

- Links the Private DNS Zone to an existing virtual network if specified.
- Enables auto-registration of virtual machine records if specified.

## Parameters

| Name                       | Type     | Required | Description                                                   |
| :------------------------- | :------: | :------: | :------------------------------------------------------------ |
| `virtualNetworkResourceId` | `string` | Yes      | Existing virtual network resource ID(s).                      |
| `registrationEnabled`      | `bool`   | No       | Optional. VNET link Auto Registration.                        |
| `name`                     | `string` | Yes      | The Private DNS Zone name.                                    |
| `location`                 | `string` | Yes      | Optional. The location where the Private DNS Zone is deployed |

## Outputs

| Name         | Type     | Description                                            |
| :----------- | :------: | :----------------------------------------------------- |
| `name`       | `string` | The name of the deployed private dns zone link.        |
| `resourceId` | `string` | The resource ID of the deployed private dns zone link. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.