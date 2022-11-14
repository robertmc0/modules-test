# ExpressRoute Gateway Module

This module deploys Microsoft.Network expressRouteGateways

## Description

This module performs the following

- Creates Microsoft.Network expressRouteGateways resource for a virtual hub.
- Enables the gateway to accept traffic from non Virtual WAN networks.
- Configure the auto scale settings.
- Applies a lock to the expressRoute gateway if the lock is specified.

## Parameters

| Name                        | Type     | Required | Description                                                                        |
| :-------------------------- | :------: | :------: | :--------------------------------------------------------------------------------- |
| `name`                      | `string` | Yes      | The resource name.                                                                 |
| `location`                  | `string` | Yes      | The geo-location where the resource lives.                                         |
| `tags`                      | `object` | No       | Optional. Resource tags.                                                           |
| `autoScaleConfiguration`    | `object` | No       | Optional. Configuration for auto scaling.                                          |
| `allowNonVirtualWanTraffic` | `bool`   | No       | Optional. Configures this gateway to accept traffic from non Virtual WAN networks. |
| `virtualHubResourceId`      | `string` | No       | Optional. Virtual Hub resource ID.                                                 |
| `resourceLock`              | `string` | No       | Optional. Specify the type of resource lock.                                       |

## Outputs

| Name       | Type   | Description                                           |
| :--------- | :----: | :---------------------------------------------------- |
| name       | string | The name of the deployed expressRoute gateway.        |
| resourceId | string | The resource ID of the deployed expressRoute gateway. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.