# Network Watchers

This module deploys Microsoft.Network networkWatchers

## Description

This module performs the following

Creates Microsoft.Network networkWatchers resource.
Applies a lock to the network watcher if the lock is specified.

## Parameters

| Name           | Type     | Required | Description                                  |
| :------------- | :------: | :------: | :------------------------------------------- |
| `name`         | `string` | Yes      | The resource name.                           |
| `location`     | `string` | Yes      | The geo-location where the resource lives.   |
| `tags`         | `object` | No       | Optional. Resource tags.                     |
| `resourcelock` | `string` | No       | Optional. Specify the type of resource lock. |

## Outputs

| Name       | Type   | Description                                      |
| :--------- | :----: | :----------------------------------------------- |
| name       | string | The name of the deployed network watcher.        |
| resourceId | string | The resource ID of the deployed network watcher. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.