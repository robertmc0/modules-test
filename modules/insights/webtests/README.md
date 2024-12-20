# Web Test Module

This module deploys a Web Test (Microsoft.Insights/webtests) resource and an associated alert on failure.

## Details

This module deploys a Web Test (Microsoft.Insights/webtests) resource and an associated alert on failure.

## Parameters

| Name                   | Type     | Required | Description                                                                                                                                                                     |
| :--------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `appInsightsId`        | `string` | Yes      | ResourceId of target App Insights for Web Test.                                                                                                                                 |
| `serviceName`          | `string` | Yes      | Name of the target service to monitor.                                                                                                                                          |
| `pingTestUrl`          | `string` | Yes      | Target URL for the Ping Test.                                                                                                                                                   |
| `actionGroups`         | `array`  | Yes      | Array of ResourceIds of Actions Groups.                                                                                                                                         |
| `location`             | `string` | No       | Optional. Location of resources.                                                                                                                                                |
| `expectedResponseCode` | `string` | No       | Optional. Response code for the GET Ping Web Test, defaulting to 200.                                                                                                           |
| `webTestLocations`     | `array`  | No       | Optional. Array of Web Test Locations as per https://learn.microsoft.com/en-us/previous-versions/azure/azure-monitor/app/monitor-web-app-availability#location-population-tags. |
| `webTestFrequency`     | `int`    | No       | Optional. Frequency of Web Test execution.                                                                                                                                      |
| `webTestTimeout`       | `int`    | No       | Optional. Timeout period for Web Test.                                                                                                                                          |
| `alertSeverity`        | `int`    | No       | Optional. Alert Severity.                                                                                                                                                       |
| `failedLocationCount`  | `int`    | No       | Optional. Number of Failed Locations until Alert.                                                                                                                               |
| `tags`                 | `object` | No       | Optional. Resource tags.                                                                                                                                                        |

## Outputs

| Name                      | Type     | Description                               |
| :------------------------ | :------: | :---------------------------------------- |
| `pingWebTestResourceId`   | `string` | The resource ID of the deployed Web Test. |
| `pingWebTestResourceName` | `string` | The name of the Web Test resource.        |
| `alertResourceId`         | `string` | The resource ID of the deployed Alert.    |
| `alertResourceName`       | `string` | The name of the Alert resource.           |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.