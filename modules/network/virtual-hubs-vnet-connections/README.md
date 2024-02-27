# Route Tables Module

This module deploys Microsoft.Network/virtualHubs hubVirtualNetworkConnections.

## Description

This module performs the following

- Creates Microsoft.Network/virtualHubs hubVirtualNetworkConnections resource.
- Enables you to to associate the connection to a route table.
- Enables you to to advertise routes from the connection to a route table.
- Configure internet security.

## Parameters

| Name                     | Type     | Required | Description                                                                            |
| :----------------------- | :------: | :------: | :------------------------------------------------------------------------------------- |
| `name`                   | `string` | Yes      | The resource name.                                                                     |
| `virtualHubName`         | `string` | Yes      | Virtual Hub name.                                                                      |
| `enableInternetSecurity` | `bool`   | No       | Optional. Enable internet security.                                                    |
| `remoteVirtualNetworkId` | `string` | Yes      | Remote virtual network resource ID.                                                    |
| `associatedRouteTableId` | `string` | No       | Optional. The resource ID of the RouteTable associated with this RoutingConfiguration. |
| `propagatedRouteTables`  | `object` | No       | Optional. The list of RouteTables to advertise the routes to.                          |

## Outputs

| Name       | Type   | Description                                        |
| :--------- | :----: | :------------------------------------------------- |
| name       | string | The name of the deployed virtual hub route.        |
| resourceId | string | The resource ID of the deployed virtual hub route. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.