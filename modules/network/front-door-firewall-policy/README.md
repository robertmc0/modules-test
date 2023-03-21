# Front Door Firewall Policy Module

This module deploys Microsoft.Network FrontDoorWebApplicationFirewallPolicies

## Description

This module performs the following

- Creates Microsoft.Network FrontDoorWebApplicationFirewallPolicies resource.
- Add policy settings if specified.
- Add custom rules if specified.
- Add manage rules and exclusions if specified.
- Applies a lock when the lock type is specified.

## Parameters

| Name             | Type     | Required | Description                                              |
| :--------------- | :------: | :------: | :------------------------------------------------------- |
| `name`           | `string` | Yes      | The resource name.                                       |
| `skuName`        | `string` | Yes      | The sku of the front door firewall policy.               |
| `tags`           | `object` | No       | Optional. Resource tags.                                 |
| `policySettings` | `object` | No       | Optional. Firewall policy settings                       |
| `customRules`    | `object` | No       | Optional. The custom rules inside the policy.            |
| `managedRules`   | `object` | No       | Optional. The Exclusions that are applied on the policy. |
| `resourceLock`   | `string` | No       | Optional. Specify the type of resource lock.             |

## Outputs

| Name       | Type   | Description                                      |
| :--------- | :----: | :----------------------------------------------- |
| name       | string | The name of the deployed firewall policy.        |
| resourceId | string | The resource ID of the deployed firewall policy. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.