# Hub Routing Intent Module

This module deploys Microsoft.Network/virtualHubs routingIntent.

## Details

{{Add detailed information about the module}}

## Parameters

| Name                        | Type     | Required | Description                                       |
| :-------------------------- | :------: | :------: | :------------------------------------------------ |
| `virtualHubName`            | `string` | Yes      | Virtual Hub name.                                 |
| `routingIntentDestinations` | `array`  | No       | Optional. The destinations of the routing intent. |
| `nextHopId`                 | `string` | Yes      | The next hop of the routing intent.               |

## Outputs

| Name         | Type     | Description                                                 |
| :----------- | :------: | :---------------------------------------------------------- |
| `name`       | `string` | The name of the deployed routing intent.                    |
| `resourceId` | `string` | The resource ID of the deployed virtual hub routing intent. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.