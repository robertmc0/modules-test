# Route Tables Module

This module deploys Microsoft.Network routeTables.

## Description

This module performs the following

- Creates Microsoft.Network routeTables resource.
- Disables the routes learned by BGP if specified.
- Applies a lock to the route table if the lock is specified.

## Parameters

| Name                         | Type     | Required | Description                                                                                     |
| :--------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------- |
| `name`                       | `string` | Yes      | The resource name.                                                                              |
| `location`                   | `string` | Yes      | The geo-location where the resource lives.                                                      |
| `tags`                       | `object` | No       | Optional. Resource tags.                                                                        |
| `disableBgpRoutePropagation` | `bool`   | No       | Optional. Whether to disable the routes learned by BGP on that route table. True means disable. |
| `routes`                     | `array`  | No       | Collection of routes contained within a route table.                                            |
| `resourceLock`               | `string` | No       | Optional. Specify the type of resource lock.                                                    |

## Outputs

| Name       | Type   | Description                                  |
| :--------- | :----: | :------------------------------------------- |
| name       | string | The name of the deployed route table.        |
| resourceId | string | The resource ID of the deployed route table. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.