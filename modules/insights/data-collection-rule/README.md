# Insights data collection rule Module.

This module deploys Microsoft.Insights dataCollectionRules.

## Details

{{Add detailed information about the module}}

## Parameters

| Name                               | Type     | Required | Description                                                                                                                                             |
| :--------------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`                             | `string` | Yes      | Required. Name of the Data collection rule.                                                                                                             |
| `location`                         | `string` | Yes      | The geo-location where the resource lives.                                                                                                              |
| `workspaceId`                      | `string` | Yes      | Required. Resource ID of the Log Analytics Workspace that has the VM Insights data.                                                                     |
| `shortenedUniqueString`            | `string` | No       | Optional. A random generated set of strings for resource naming                                                                                         |
| `tags`                             | `object` | No       | Optional. Resource tags.                                                                                                                                |
| `kind`                             | `string` | No       | The operating system kind in which DCR will be configured to.                                                                                           |
| `dataCollectionEndpointId`         | `string` | No       | Optional. The resource ID of the data collection endpoint that this rule can be used with.                                                              |
| `performanceCounterSpecifiers`     | `array`  | No       | Optional. A list of specifier names for VM Performance telemetry to collect.                                                                            |
| `insightsMetricsCounterSpecifiers` | `array`  | No       | Optional. A list of specifier names for VM insights telemetry to collect.                                                                               |
| `eventLogsxPathQueries`            | `array`  | No       | Optional. A list of Windows Event Log queries in XPATH format. Only applicable if kind is Windows.                                                      |
| `destinationFriendlyName`          | `string` | No       | Optional. A friendly name for the destination. This name should be unique across all destinations (regardless of type) within the data collection rule. |
| `dataFlows`                        | `array`  | No       | Optional. The specification of data flows.                                                                                                              |
| `dcrExtensions`                    | `array`  | No       | Optional. The list of Azure VM extension data source configurations.                                                                                    |

## Outputs

| Name             | Type     | Description                                                         |
| :--------------- | :------: | :------------------------------------------------------------------ |
| `dcrId`          | `string` | The resource id of the data collection rule (DCR).                  |
| `dcrPrincipalId` | `string` | The principal id of the data collection rule for identity purposes. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.