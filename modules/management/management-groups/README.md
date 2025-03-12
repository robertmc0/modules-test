# Management Groups

This module deploys Microsoft.Management managementGroups

## Description

This module performs the following

- Creates Microsoft.Management managementGroups resource.
- Applies management group as a child if parent specified.

## Parameters

| Name          | Type     | Required | Description                                                             |
| :------------ | :------: | :------: | :---------------------------------------------------------------------- |
| `name`        | `string` | Yes      | The resource name. This is also referred to as the management group ID. |
| `displayName` | `string` | Yes      | The friendly name of the management group.                              |
| `parent`      | `string` | No       | Optional. The ID of the parent management group.                        |

## Outputs

| Name       | Type   | Description                                       |
| :--------- | :----: | :------------------------------------------------ |
| name       | string | The name of the deployed management group.        |
| resourceId | string | The resource ID of the deployed management group. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.