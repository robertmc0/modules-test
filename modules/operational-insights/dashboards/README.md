# Azure Dashboards

Deploy Azure Dashboards

## Details

This module performs the following:

- Creates a Microsoft.Portal/dashboards resource.

## Parameters

| Name           | Type                | Required | Description                                               |
| :------------: | :-----------------: | :------: | :-------------------------------------------------------: |
| `name`         | `string`            | Yes      | The name for the dashboard.                               |
| `tiles`        | `Types.Tiles`       | Yes      | The array of tiles that make up the Dashboard visually.   |
| `tilePositions`| `Types.Positions`   | No       | Optional overrides for the positions of the tiles.        |
| `location`     | `string`            | No       | The location for the dashboard.                           |
| `rowCount`     | `Types.PositiveInt` | No       | The maximum number of tiles per row in the dashboard.     |
| `columnCount`  | `Types.PositiveInt` | No       | The maximum number of tiles per column in the dashboard.  |
| `tileWidth`    | `Types.PositiveInt` | No       | The width of each tile.                                   |
| `tileHeight`   | `Types.PositiveInt` | No       | The height of each tile.                                  |

## Outputs

| Name         | Type     | Description                                |
| :----------: | :------: | :----------------------------------------: |
| `resourceId` | `string` | The resource ID of the deployed Dashboard. |

## Types

| Name                   | Description                                                                                     |
| :--------------------: | :---------------------------------------------------------------------------------------------: |
| `PositiveInt`          | A positive integer.                                                                             |
| `Tile`                 | An individual tile or section within the dashboard.                                             |
| `Tiles`                | A collection of tiles.                                                                          |
| `MetricGrouping`       | Describes how a given metric should be split or grouped by.                                     |
| `AppInsightsTimeRange` | The time range for an Application Insights query.                                               |
| `Metric`               | A specific metric within Azure Monitor.                                                         |
| `Metrics`              | A collection of metrics.                                                                        |
| `ChartType`            | Specifies the style of the chart, such as if it's a bar chart, or an area chart.                |
| `Filter`               | Describes how a given metric would be filtered.                                                 |
| `Filters`              | A collection of filters.                                                                        |
| `Position`             | The position on the dashboard for a given tile.                                                 |
| `Positions`            | A collection of positions.                                                                      |

## Examples

### Example 1

See [Tests File](test/main.test.bicep)
