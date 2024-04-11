# Azure Firewall Policy Module

This module deploys Microsoft.Network firewallPolicies

## Description

This module performs the following

- Creates Microsoft.Network azureFirewalls resource.
- Optionally enables [Threat Intelligence](https://learn.microsoft.com/en-us/azure/firewall/threat-intel) with support for allow lists.
- Optionally enables the system and user assigned managed identity on the resource.
- Optionally enables DNS proxy with support for custom DNS servers.
- Optionally enables [Intrusion Detection and Prevention System](https://learn.microsoft.com/en-us/azure/firewall/premium-features#idps) with support for bypass rules.
- Optionally enables [TLS Inspection](https://learn.microsoft.com/en-us/azure/firewall/premium-features#tls-inspection) with integration with key vault for certiciates.
- Optionally enables a resource lock on the resource.

> Note: TLS Inspection, IDPS, URL Filtering and Web Categories are only available on the Premium SKU.

> Note: Custom DNS Servers & DNS Proxy are unavailable on the Basic SKU. These values will be filtered out if the `tier` variable is passed as "Basic"

> Note: Azure RBAC is not currently supported for key vault integration with Azure Firewall Policy, refer to: https://learn.microsoft.com/en-us/azure/firewall/premium-certificates#azure-key-vault

## Parameters

| Name                     | Type     | Required | Description                                                                          |
| :----------------------- | :------: | :------: | :----------------------------------------------------------------------------------- |
| `name`                   | `string` | Yes      | The resource name.                                                                   |
| `location`               | `string` | Yes      | The geo-location where the resource lives.                                           |
| `tags`                   | `object` | No       | Optional. Resource tags.                                                             |
| `tier`                   | `string` | Yes      | Tier of an Azure Firewall.                                                           |
| `threatIntelMode`        | `string` | No       | Optional. The operation mode for Threat Intelligence.                                |
| `threatIntelAllowlist`   | `object` | No       | Optional. Threat Intelligence Allowlist.                                             |
| `systemAssignedIdentity` | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                  |
| `userAssignedIdentities` | `object` | No       | Optional. The ID(s) to assign to the resource.                                       |
| `enableDnsProxy`         | `bool`   | No       | Optional. Enable DNS Proxy on Firewalls attached to the Firewall Policy.             |
| `customDnsServers`       | `array`  | No       | Optional. List of Custom DNS Servers. Only required when enableDnsProxy set to true. |
| `intrusionDetection`     | `object` | No       | Optional. Intrusion Detection Configuration. Requires Premium SKU.                   |
| `transportSecurity`      | `object` | No       | Optional. TLS Configuration definition. Requires Premium SKU.                        |
| `resourceLock`           | `string` | No       | Optional. Specify the type of resource lock.                                         |

## Outputs

| Name         | Type     | Description                                            |
| :----------- | :------: | :----------------------------------------------------- |
| `name`       | `string` | The name of the deployed Azure firewall policy.        |
| `resourceId` | `string` | The resource ID of the deployed Azure firewall policy. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.