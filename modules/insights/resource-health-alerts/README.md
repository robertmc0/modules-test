# Insights Resource Health Alert Module

This module deploys Microsoft.Insights activityLogAlerts

## Description

This module performs the following

- Creates Microsoft.Insights activityLogAlerts resource.
- Applies the scope of the alert if specified.
- Applies the resource types if specified.

## Parameters

| Name             | Type     | Required | Description                                                                                                                                                               |
| :--------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`           | `string` | Yes      | The resource name.                                                                                                                                                        |
| `actionGroupIds` | `array`  | Yes      | Action Group Resource IDs.                                                                                                                                                |
| `scopes`         | `array`  | No       | Optional. A list of resource IDs that will be used as prefixes. The alert will only apply to Activity Log events with resource IDs that fall under one of these prefixes. |
| `resourceTypes`  | `array`  | No       | Optional. A list of resource type resource IDs to filter against. Leave empty to add all resource types.                                                                  |

## Outputs

| Name       | Type   | Description                                            |
| :--------- | :----: | :----------------------------------------------------- |
| name       | string | The name of the deployed resource health alert.        |
| resourceId | string | The resource ID of the deployed resource health alert. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.