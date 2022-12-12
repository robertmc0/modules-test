# Insights Service Health Alerts Module

This module deploys Microsoft.Insights activityLogAlerts

## Description

This module performs the following

- Creates Microsoft.Insights activityLogAlerts resource.
- Applies the scope of the alert if specified.
- Applies the incident types if specified.
- Applies specific regions to alert on if specified.

## Parameters

| Name             | Type     | Required | Description                                                                                                                                                               |
| :--------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`           | `string` | Yes      | The resource name.                                                                                                                                                        |
| `actionGroupIds` | `array`  | Yes      | Action Group Resource IDs.                                                                                                                                                |
| `scopes`         | `array`  | No       | Optional. A list of resource IDs that will be used as prefixes. The alert will only apply to Activity Log events with resource IDs that fall under one of these prefixes. |
| `serviceNames`   | `array`  | No       | Optional. Azure Services to scope to Service Health alert. Leave empty to add all services.                                                                               |
| `incidentTypes`  | `array`  | No       | Optional. Incident Types to scope to Service Health alert. Leave empty to add all incident types.                                                                         |
| `regions`        | `array`  | No       | Optional. Regions to scope to Service Health alert. Leave empty to add all regions.                                                                                       |

## Outputs

| Name       | Type   | Description                                           |
| :--------- | :----: | :---------------------------------------------------- |
| name       | string | The name of the deployed service health alert.        |
| resourceId | string | The resource ID of the deployed service health alert. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.