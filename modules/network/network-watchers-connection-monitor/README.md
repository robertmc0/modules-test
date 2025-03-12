# Connection Monitors Module

This module deploys Microsoft.Network/networkWatchers connectionMonitors.

## Details

This module performs the following

- Creates Microsoft.Network/networkWatchers connectionMonitors resource.

## Parameters

| Name                      | Type            | Required | Description                                                                                        |
| :------------------------ | :-------------: | :------: | :------------------------------------------------------------------------------------------------- |
| `name`                    | `string`        | Yes      | The resource name.                                                                                 |
| `networkWatcherName`      | `string`        | No       | Optional. Network Watcher name. Default is NetworkWatcher_<location>.                              |
| `tags`                    | `null | object` | No       | Optional. Resource tags.                                                                           |
| `location`                | `string`        | Yes      | The geo-location where the resource lives.                                                         |
| `endpoints`               | `array`         | Yes      | List of connection monitor endpoints. At least one source and one destination must be specified.   |
| `testConfigurations`      | `array`         | Yes      | List of connection monitor test configurations. At least one test configuration must be specified. |
| `testGroups`              | `array`         | Yes      | List of connection monitor test groups. At least one test group must be specified.                 |
| `logAnalyticsWorkspaceId` | `null | string` | No       | Optional. Specify the Log Analytics Workspace Resource ID.                                         |

## Outputs

| Name         | Type     | Description                                         |
| :----------- | :------: | :-------------------------------------------------- |
| `name`       | `string` | The name of the deployed connection monitor.        |
| `resourceId` | `string` | The resource ID of the deployed connection monitor. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.