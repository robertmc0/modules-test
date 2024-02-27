# Policy Assignment Module

This module deploys Microsoft.Authorization policyAssignments at the management group level.

## Description

This module performs the following

- Creates Microsoft.Authorization policyAssignments resource.

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/policyAssignments` | [2021-06-01](https://learn.microsoft.com/en-us/azure/templates/microsoft.authorization/2021-06-01/policyassignments?pivots=deployment-language-bicep) |

## Parameters

| Name                     | Type     | Required | Description                                                                                              |
| :----------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------- |
| `name`                   | `string` | Yes      | Specifies the name of the policy assignment. Maximum length is 24 characters for management group scope. |
| `location`               | `string` | No       | Optional. The location of the policy assignment. Only required when utilizing managed identity.          |
| `displayName`            | `string` | Yes      | The display name of the policy assignment. Maximum length is 128 characters.                             |
| `description`            | `string` | Yes      | This message will be part of response in case of policy violation.                                       |
| `enforcementMode`        | `string` | No       | Optional. The policy assignment enforcement mode.                                                        |
| `systemAssignedIdentity` | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                      |
| `userAssignedIdentities` | `object` | No       | Optional. The ID(s) to assign to the resource.                                                           |
| `nonComplianceMessage`   | `string` | No       | Optional. The message that describe why a resource is non-compliant with the policy.                     |
| `notScopes`              | `array`  | No       | Optional. The policy excluded scopes.                                                                    |
| `parameters`             | `object` | No       | Optional. The parameter values for the assigned policy rule. The keys are the parameter names.           |
| `policyDefinitionId`     | `string` | Yes      | The ID of the policy definition or policy set definition being assigned.                                 |

## Outputs

| Name                      | Type   | Description                                       |
| :------------------------ | :----: | :------------------------------------------------ |
| name                      | string | The name of the policy assignment.                |
| resourceId                | string | The resource ID of the policy assignment.         |
| systemAssignedPrincipalId | string | The principal ID of the system assigned identity. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.