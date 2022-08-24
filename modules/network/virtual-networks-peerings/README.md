# Virtual Network Peerings Module

This module deploys Microsoft.Network virtualNetworks/virtualNetworkPeerings.

## Description

This module performs the following

- Creates Microsoft.Network virtualNetworks/virtualNetworkPeerings resource.
- Sets the peering sync level if specified.

## Parameters

| Name                        | Type     | Required | Description                                                                                                                   |
| :-------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------- |
| `name`                      | `string` | Yes      | The resource name.                                                                                                            |
| `sourceVirtualNetworkName`  | `string` | Yes      | Name of the source virtual network that is being peered.                                                                      |
| `allowForwardedTraffic`     | `bool`   | Yes      | Whether the forwarded traffic from the VMs in the local virtual network will be allowed/disallowed in remote virtual network. |
| `allowGatewayTransit`       | `bool`   | Yes      | If gateway links can be used in remote virtual networking to link to this virtual network.                                    |
| `allowVirtualNetworkAccess` | `bool`   | Yes      | Whether the VMs in the local virtual network space would be able to access the VMs in remote virtual network space.           |
| `doNotVerifyRemoteGateways` | `bool`   | No       | Optional. Do not verify the provisioning state of the remote gateway.                                                         |
| `remoteVirtualNetworkId`    | `string` | Yes      | Remote virtual network resource id.                                                                                           |
| `useRemoteGateways`         | `bool`   | Yes      | If remote gateways can be used on this virtual network.                                                                       |
| `peeringSyncLevel`          | `string` | No       | Optional. The peering sync status of the virtual network peering.                                                             |

## Outputs

| Name       | Type   | Description                                              |
| :--------- | :----: | :------------------------------------------------------- |
| name       | string | The name of the deployed virtual network peering.        |
| resourceId | string | The resource ID of the deployed virtual network peering. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.