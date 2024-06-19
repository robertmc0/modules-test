# Operational Insights Dashboard Module.

This module deploys a Microsoft.Portal/dashboards resource.

## Details

{{Add detailed information about the module}}

## Parameters

| Name            | Type     | Required | Description                                                                |
| :-------------- | :------: | :------: | :------------------------------------------------------------------------- |
| `tags`          | `object` | No       | Optional. Resource tags.                                                   |
| `location`      | `string` | No       | Optional. The location for the dashboard.                                  |
| `tilePositions` | `array`  | No       | Optional. A given set of tile positions that overrides the default layout. |
| `name`          | `string` | Yes      | The name for the dashboard.                                                |
| `tiles`         | `array`  | Yes      | The array of tiles that make up the Dashboard visually.                    |
| `rowCount`      | `int`    | No       | Optional. The maximum number of tiles per row in the dashboard.            |
| `columnCount`   | `int`    | No       | Optional. The maximum number of tiles per column in the dashboard.         |
| `tileWidth`     | `int`    | No       | Optional. The width of each tile.                                          |
| `tileHeight`    | `int`    | No       | Optional. The height of each tile.                                         |

## Outputs

| Name         | Type     | Description                       |
| :----------- | :------: | :-------------------------------- |
| `resourceId` | `string` | The resource ID of the dashboard. |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```