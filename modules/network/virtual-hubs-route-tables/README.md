# Hub Route Tables Module

This module deploys Microsoft.Network/virtualHubs hubRouteTables.

## Description

This module performs the following

- Creates Microsoft.Network/virtualHubs hubRouteTables resource.
- Creates a single or multiple routes in route table.
- Applies a lock to the virtual network if the lock is specified.

## Parameters

| Name             | Type     | Required | Description                                                |
| :--------------- | :------: | :------: | :--------------------------------------------------------- |
| `name`           | `string` | Yes      | The resource name.                                         |
| `labels`         | `array`  | No       | Optional. List of labels associated with this route table. |
| `routes`         | `array`  | No       | Optional. List of all routes.                              |
| `virtualHubName` | `string` | Yes      | Virtual Hub name.                                          |
| `resourceLock`   | `string` | No       | Optional. Specify the type of resource lock.               |

## Outputs

| Name       | Type   | Description                                        |
| :--------- | :----: | :------------------------------------------------- |
| name       | string | The name of the deployed virtual hub route.        |
| resourceId | string | The resource ID of the deployed virtual hub route. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.