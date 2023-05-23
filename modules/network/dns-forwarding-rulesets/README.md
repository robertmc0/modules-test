# DNS Private Resolver Module

This module deploys Microsoft.Network dnsResolvers.

## Description

This module performs the following

- Creates Microsoft.Network privateDnsZones resource.
- Links the Private DNS Zone to an existing virtual network if specified.
- Enables auto-registration of virtual machine records if specified.
- Applies a lock to the Private DNS Zone if the lock is specified.

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