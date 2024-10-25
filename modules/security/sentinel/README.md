# Sentinel Module

This module deploys Azure Sentinel

## Details

{{Add detailed information about the module}}

## Parameters

| Name                | Type     | Required | Description                                                                                                                                                                                     |
| :------------------ | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `location`          | `string` | Yes      | The geo-location where the resource lives.                                                                                                                                                      |
| `workspaceId`       | `string` | Yes      | Log analytics workspace resource ID.                                                                                                                                                            |
| `dataSources`       | `array`  | No       | Optional. Data sources to add to Sentinel.                                                                                                                                                      |
| `connectors`        | `array`  | No       | Optional. Connectors to be added to Sentinel.                                                                                                                                                   |
| `alertRules`        | `array`  | No       | Optional. Incident creation alert rules to be added to Sentinel.                                                                                                                                |
| `winEventProviders` | `array`  | No       | Optional. A list of Windows Event Providers that you would like to collect. Windows Security Auditing is not enabled through this option. It is enabled through Azure Sentinel Data Connectors. |
| `winEventTypes`     | `array`  | No       | Optional. A list of Windows Event Types that you would like to collect.                                                                                                                         |
| `syslogFacilities`  | `array`  | No       | Optional. A list of facilities to collect from Syslog.                                                                                                                                          |
| `syslogSeverities`  | `array`  | No       | Optional. A list of severities to collect from Syslog.                                                                                                                                          |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.