# Role Assignments Module

This module deploys Microsoft.Authorization roleAssignments

## Description

This module performs the following

- Creates Microsoft.Authorization roleAssignments resource.

## Parameters

| Name               | Type     | Required | Description                                                               |
| :----------------- | :------: | :------: | :------------------------------------------------------------------------ |
| `name`             | `string` | No       | Optional. The resource name. Must be a globally unique identifier (GUID). |
| `roleDefinitionId` | `string` | Yes      | The role definition ID.                                                   |
| `principalType`    | `string` | Yes      | The principal type of the assigned principal ID.                          |
| `principalId`      | `string` | Yes      | The principal ID.                                                         |

## Outputs

| Name       | Type   | Description                                      |
| :--------- | :----: | :----------------------------------------------- |
| name       | string | The name of the deployed role assignment.        |
| resourceId | string | The resource ID of the deployed role assignment. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.