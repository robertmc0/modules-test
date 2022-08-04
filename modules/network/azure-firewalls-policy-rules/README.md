# Azure Firewalls Policy Rules Module

This module deploys Microsoft.Network firewallPolicies/ruleCollectionGroups

## Description

This module performs the following

- Adds rules to an existing firewall policy.

## Parameters

| Name                 | Type     | Required | Description                           |
| :------------------- | :------: | :------: | :------------------------------------ |
| `firewallPolicyName` | `string` | Yes      | Name of the existing firewall policy. |
| `rules`              | `array`  | No       | Optional. Firewall policy rules.      |

## Outputs

| Name       | Type   | Description                                      |
| :--------- | :----: | :----------------------------------------------- |
| name       | string | The name of the deployed firewall policy.        |
| resourceId | string | The resource ID of the deployed firewall policy. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.