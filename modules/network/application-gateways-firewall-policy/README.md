# Application Gateway Firewall Policy Module

This module deploys Microsoft.Network ApplicationGatewayWebApplicationFirewallPolicies

## Description

This module performs the following

- Creates Microsoft.Network ApplicationGatewayWebApplicationFirewallPolicies resource.
- Add policy settings if specified.
- Add custom rules if specified.
- Add manage rule sets and exclusions if specified.
- Applies a lock to the bastion host if the lock is specified.

## Parameters

| Name                    | Type     | Required | Description                                                          |
| :---------------------- | :------: | :------: | :------------------------------------------------------------------- |
| `name`                  | `string` | Yes      | The resource name.                                                   |
| `location`              | `string` | Yes      | The geo-location where the resource lives.                           |
| `tags`                  | `object` | No       | Optional. Resource tags.                                             |
| `policySettings`        | `object` | No       | Optional. Firewall policy settings.                                  |
| `customRules`           | `array`  | No       | Optional. The custom rules inside the policy.                        |
| `managedRuleSets`       | `array`  | No       | Optional. The managed rule sets that are associated with the policy. |
| `managedRuleExclusions` | `array`  | No       | Optional. The Exclusions that are applied on the policy.             |
| `resourceLock`          | `string` | No       | Optional. Specify the type of resource lock.                         |

## Outputs

| Name       | Type   | Description                                      |
| :--------- | :----: | :----------------------------------------------- |
| name       | string | The name of the deployed firewall policy.        |
| resourceId | string | The resource ID of the deployed firewall policy. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.