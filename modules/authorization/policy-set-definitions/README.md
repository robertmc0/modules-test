# Policy Set Definitions Module

This module deploys Microsoft.Authorization policySetDefinitions

## Description

This module performs the following

- Creates Microsoft.Authorization policySetDefinitions resource.

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/policySetDefinitions` | [2021-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policysetdefinitions?pivots=deployment-language-bicep) |

## Parameters

| Name                     | Type     | Required | Description                                                                                                                                                                          |
| :----------------------- | :------: | :------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                   | `string` | Yes      | Required. Specifies the name of the policy Set Definition (Initiative).                                                                                                              |
| `description`            | `string` | Yes      | Required. The description name of the Set Definition (Initiative).                                                                                                                   |
| `displayName`            | `string` | Yes      | Required. The display name of the Set Definition (Initiative). Maximum length is 128 characters.                                                                                     |
| `parameters`             | `object` | No       | Optional. The policy set definition parameters that can be used in policy definition references.                                                                                     |
| `metadata`               | `object` | No       | Optional. The Set Definition (Initiative) metadata. Metadata is an open ended object and is typically a collection of key-value pairs.                                               |
| `policyDefinitions`      | `array`  | Yes      | Required. The array of Policy definitions object to include for this policy set. Each object must include the Policy definition ID, and optionally other properties like parameters. |
| `policyDefinitionGroups` | `array`  | No       | Optional. The metadata describing groups of policy definition references within the Policy Set Definition (Initiative).                                                              |

## Outputs

| Name       | Type   | Description                                            |
| :--------- | :----: | :----------------------------------------------------- |
| name       | string | The name of the deployed policy set definition.        |
| resourceId | string | The resource ID of the deployed policy set definition. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.