# Role definitions module

Deploys a custom RBAC role at the subscription level

## Details

This module is used to deploy custom RBAC roles to Azure.

## Parameters

| Name              | Type     | Required | Description                                         |
| :---------------- | :------: | :------: | :-------------------------------------------------- |
| `roleName`        | `string` | Yes      | The display name of the custom role to be deployed. |
| `roleDescription` | `string` | Yes      | The description for the custom role to be deployed. |
| `actions`         | `array`  | Yes      | List of permissions for role actions.               |
| `notActions`      | `array`  | No       | List of permissions for role not actions.           |
| `dataActions`     | `array`  | No       | List of permissions for role data actions.          |
| `notDataActions`  | `array`  | No       | List of permissions for role not data actions.      |

## Outputs

| Name         | Type     | Description                                                                                      |
| :----------- | :------: | :----------------------------------------------------------------------------------------------- |
| `resourceId` | `string` | The resource ID of the deployed custom role definition.                                          |
| `name`       | `string` | The name of the deployed custom role definition. This is usually the globally unique identifier. |

## Examples

Role definitions are defined in the roleDefinition varable. Refer to the examples in the test template [here](test/main.test.bicep)

### Subscription

```
var roleDefinitions = [
  {
    scope: '01234567-0123-0123-0123-0123456789B'
    scopeType: 'subscription'
    roleName: 'App Insights Configuration Reader'
    roleDescription: 'This is a description for the custom role definition'
    actions: [
      'microsoft.web/*/read'
      'microsoft.insights/*/read'
    ]
  }
]
```