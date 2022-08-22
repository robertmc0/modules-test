# Policy Set Definitions Module

This module deploys Microsoft.Authorization policySetDefinitions

## Description

This module performs the following

- Creates Microsoft.Authorization policySetDefinitions resource.

## Parameters

| Name                | Type     | Required | Description                                                                                      |
| :------------------ | :------: | :------: | :----------------------------------------------------------------------------------------------- |
| `name`              | `string` | Yes      | The resource name.                                                                               |
| `description`       | `string` | Yes      | The policy set definition description.                                                           |
| `displayName`       | `string` | Yes      | The display name of the policy set definition.                                                   |
| `parameters`        | `object` | No       | Optional. The policy set definition parameters that can be used in policy definition references. |
| `policyDefinitions` | `array`  | Yes      | Policy definition references.                                                                    |

## Outputs

| Name       | Type   | Description                                            |
| :--------- | :----: | :----------------------------------------------------- |
| name       | string | The name of the deployed policy set definition.        |
| resourceId | string | The resource ID of the deployed policy set definition. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.