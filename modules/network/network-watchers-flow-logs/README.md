# Flow Logs Module

This module deploys Microsoft.Network/networkWatchers flowLogs.

## Description

This module performs the following

- Creates Microsoft.Network/networkWatchers flowLogs resource.

## Parameters

| Name                       | Type     | Required | Description                                                                                              |
| :------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------- |
| `name`                     | `string` | Yes      | The resource name.                                                                                       |
| `location`                 | `string` | Yes      | The geo-location where the resource lives.                                                               |
| `tags`                     | `object` | No       | Optional. Resource tags.                                                                                 |
| `networkWatcherName`       | `string` | Yes      | Network Watcher name.                                                                                    |
| `retention`                | `int`    | No       | Optional. Number of days to retain flow log records.                                                     |
| `enableFlowLogs`           | `bool`   | No       | Optional. Flag to enable/disable flow logging.                                                           |
| `enableTrafficAnalytics`   | `bool`   | No       | Optional. Flag to enable/disable traffic analytics.                                                      |
| `trafficAnalyticsInterval` | `int`    | No       | Optional. The interval in minutes which would decide how frequently TA service should do flow analytics. |
| `networkSecurityGroupId`   | `string` | Yes      | Resource ID of the network security group to which flow log will be applied.                             |
| `storageAccountId`         | `string` | Yes      | Resource ID of the storage account which is used to store the flow log.                                  |
| `logAnalyticsWorkspaceId`  | `string` | No       | Optional. Resource ID of the log analytics workspace which is used to store the flow log.                |

## Outputs

| Name       | Type   | Description                               |
| :--------- | :----: | :---------------------------------------- |
| name       | string | The name of the deployed flow log.        |
| resourceId | string | The resource ID of the deployed flow log. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.