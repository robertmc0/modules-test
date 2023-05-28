# IpGroups Module

This module deploys Microsoft.Network ipGroups

## Description

This module performs the following

- Creates Microsoft.Network ipGroups resource.
- Applies a lock to the ipGroup if the lock is specified.

## Parameters

| Name           | Type     | Required | Description                                             |
| :------------- | :------: | :------: | :------------------------------------------------------ |
| `name`         | `string` | Yes      | The resource name.                                      |
| `location`     | `string` | Yes      | The geo-location where the resource lives.              |
| `tags`         | `object` | No       | Optional. Resource tags.                                |
| `ipAddresses`  | `array`  | Yes      | IpAddresses/IpAddressPrefixes in the IpGroups resource. |
| `resourceLock` | `string` | No       | Optional. Specify the type of resource lock.            |

## Outputs

| Name       | Type   | Description                              |
| :--------- | :----: | :--------------------------------------- |
| name       | string | The name of the deployed IpGroup.        |
| resourceId | string | The resource ID of the deployed IpGroup. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.