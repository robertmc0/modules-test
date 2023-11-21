# Hub Routing Intent Module

This module deploys Microsoft.Network/virtualHubs routingIntent.

## Details

This module performs the following

- Creates Microsoft.Network/virtualHubs routingIntent resource.
- Creates a single or multiple route intents within the routing intent policy.

## Parameters

| Name                        | Type     | Required | Description                                       |
| :-------------------------- | :------: | :------: | :------------------------------------------------ |
| `virtualHubName`            | `string` | Yes      | Virtual Hub name.                                 |
| `routingIntentDestinations` | `array`  | No       | Optional. The destinations of the routing intent. |

## Outputs

| Name         | Type     | Description                                                 |
| :----------- | :------: | :---------------------------------------------------------- |
| `name`       | `string` | The name of the deployed routing intent.                    |
| `resourceId` | `string` | The resource ID of the deployed virtual hub routing intent. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.