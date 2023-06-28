# Role definitions module

Use this module to deploy a custom RBAC role to an Azure subscription or management group

## Description

This module is used to deploy custom RBAC roles to Azure. Keep in mind that `notActions`, `dataActions` and `notDataActions` cannot be deployed under management group scope. This is a limitation with Bicep.

For a list of role operations, refer to the link below
https://learn.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations

## Parameters

| Name              | Type     | Required | Description                                                                                                  |
| :---------------- | :------: | :------: | :----------------------------------------------------------------------------------------------------------- |
| `scopeType`       | `string` | Yes      | The value that defines whether the role assignment will be deployed to a subscription or a management group. |
| `roleName`        | `string` | Yes      | The display name of the custom role to be deployed.                                                          |
| `roleDescription` | `string` | Yes      | The description for the custom role to be deployed.                                                          |
| `scopeId`         | `string` | Yes      | The target id of the deployment scope.                                                                       |
| `actions`         | `array`  | Yes      | List of permissions for role actions.                                                                        |
| `notActions`      | `array`  | Yes      | List of permissions for role not actions.                                                                    |
| `dataActions`     | `array`  | Yes      | List of permissions for role data actions.                                                                   |
| `notDataActions`  | `array`  | Yes      | List of permissions for role not data actions.                                                               |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

Role definitions are defined in the roleDefinition varable. Refer to the examples below for reference

### Management group

```
var roleDefinitions = [
  {
    scopeId: 'mgmtgroup'
    scopeType: 'managementGroup'
    roleName: 'Custom Role Name'
    roleDescription: 'This is a description for the custom role definition'
    actions: [
      'microsoft.web/*/read'
      'microsoft.insights/*/read'
    ]
    notActions: []
    dataActions: []
    notDataActions: []
  }
]
```

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
    notActions: []
    dataActions: []
    notDataActions: []
  }
]
```