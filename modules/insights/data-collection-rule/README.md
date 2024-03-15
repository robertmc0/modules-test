# Insights data collection rule Module.

This module deploys Microsoft.Insights dataCollectionRules.

## Details

Deploying this module performs the following.

Disclaimer 1: This module depends on an existing Log Analytics workspace. The workspaceId param can be used to parse the Log Analytic Workspace resource ID to this module.

Disclaimer 2: While DCR has 3 kinds (Windows, Linux and All), the DCR resource template does not accept 'All' as an input value. The only way to deploy an 'All' type DCR is to not include the kind property. Therefore, a separate dcr resource template is also included as dcrMultiOs.

- Creates Microsoft.Insights dataCollectionRules resource.
- Deploys 'Windows', 'Linux' and 'All' DCR types based on value input of the param kind
- Default values for Windows and Linux type DCRs have been defined within this module. This reflects on DCR settings most commonly found when deployed in vanilla state.
- Additional VM extensions may be scoped to Azure Monitor by specifying the VM extension Id in the dcrExtensions parameters.

## Parameters

| Name                               | Type     | Required | Description                                                                                                                                             |
| :--------------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`                             | `string` | Yes      | Required. Name of the Data collection rule.                                                                                                             |
| `location`                         | `string` | Yes      | The geo-location where the resource lives.                                                                                                              |
| `workspaceId`                      | `string` | Yes      | Required. Resource ID of the Log Analytics Workspace that has the VM Insights data.                                                                     |
| `shortenedUniqueString`            | `string` | No       | Optional. A random generated set of strings for resource naming.                                                                                        |
| `tags`                             | `object` | No       | Optional. Resource tags.                                                                                                                                |
| `kind`                             | `string` | Yes      | Required. The operating system kind in which DCR will be configured to.                                                                                 |
| `dataCollectionEndpointId`         | `string` | No       | Required. The resource ID of the data collection endpoint that this rule can be used with.                                                              |
| `performanceCounterSpecifiers`     | `array`  | No       | Optional. A list of specifier names for VM Performance telemetry to collect.                                                                            |
| `insightsMetricsCounterSpecifiers` | `array`  | No       | Optional. A list of specifier names for VM insights telemetry to collect.                                                                               |
| `eventLogsxPathQueries`            | `array`  | No       | Optional. A list of Windows Event Log queries in XPATH format. Only applicable if kind is Windows.                                                      |
| `destinationFriendlyName`          | `string` | No       | Optional. A friendly name for the destination. This name should be unique across all destinations (regardless of type) within the data collection rule. |
| `dataFlows`                        | `array`  | No       | Optional. The specification of data flows.                                                                                                              |
| `dcrExtensions`                    | `array`  | No       | Optional. The list of Azure VM extension data source configurations.                                                                                    |

## Outputs

| Name                        | Type     | Description                                                                         |
| :-------------------------- | :------: | :---------------------------------------------------------------------------------- |
| `resourceId`                | `string` | The resource id of the data collection rule (DCR).                                  |
| `name`                      | `string` | The resource name of the data collection rule (DCR).                                |
| `systemAssignedPrincipalId` | `string` | The system assigned principal id of the data collection rule for identity purposes. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.