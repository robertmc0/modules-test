# DNS Forwarding Ruleset Module

This module deploys Microsoft.Network dnsForwardingRulesets.

## Description

This module performs the following

- Creates Microsoft.Network dnsForwardingRulesets resource.
- Used in conjunction with a deployed Private DNS Resolver (see separate module dns-resolvers to deploy).
- Can create multiple rules for the ruleset by specifying inside an array - see test file for details.
- Links the created DNS Forwarding Ruleset to an existing virtual network where the Private DNS Resolver is deployed.
- Associates the created Ruleset to the Outbound Endpoint on the previously created Private DNS Resolver.
- Applies a lock to the DNS Forwarding Ruleset if the lock is specified.

## Parameters

| Name                 | Type     | Required | Description                                                                            |
| :------------------- | :------: | :------: | :------------------------------------------------------------------------------------- |
| `name`               | `string` | Yes      | The resource name.                                                                     |
| `location`           | `string` | Yes      | The geo-location where the resource lives.                                             |
| `tags`               | `object` | No       | Optional. Resource tags.                                                               |
| `virtualNetworkId`   | `string` | Yes      | Existing virtual network resource id where the private dns resolver has been deployed. |
| `outboundEndpointId` | `string` | Yes      | Existing dns resolver outbound endpoint resource id.                                   |
| `dnsFwdRules`        | `array`  | Yes      | Define dns fowarding rules to be applied to this ruleset.                              |
| `resourceLock`       | `string` | No       | Optional. Specify the type of resource lock.                                           |

## Outputs

| Name       | Type   | Description                                             |
| :--------- | :----: | :------------------------------------------------------ |
| name       | string | The name of the deployed DNS Forwarding Ruleset.        |
| resourceid | string | The resource ID of the deployed DNS Forwarding Ruleset. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.