# User Assigned Identity Module

This module deploys userAssignedIdentities resource.

## Description

This module performs the following

- Creates Microsoft.ManagedIdentity userAssignedIdentities resource.
- Applies a lock to the bastion host if the lock is specified.

## Parameters

| Name           | Type     | Required | Description                                  |
| :------------- | :------: | :------: | :------------------------------------------- |
| `name`         | `string` | Yes      | The resource name.                           |
| `location`     | `string` | Yes      | The geo-location where the resource lives.   |
| `tags`         | `object` | No       | Optional. Resource tags.                     |
| `resourceLock` | `string` | No       | Optional. Specify the type of resource lock. |

## Outputs

| Name        | Type   | Description                                              |
| :---------- | :----: | :------------------------------------------------------- |
| name        | string | The name of the deployed user assigned identity.         |
| resourceId  | string | The resource ID of the deployed user assigned identity.  |
| principalId | string | The principal ID of the deployed user assigned identity. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.