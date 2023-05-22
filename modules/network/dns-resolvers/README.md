# DNS Private Resolver Module

This module deploys Microsoft.Network dnsResolvers.

## Description

This module performs the following

- Creates Microsoft.Network privateDnsZones resource.
- Links the Private DNS Zone to an existing virtual network if specified.
- Enables auto-registration of virtual machine records if specified.
- Applies a lock to the Private DNS Zone if the lock is specified.

## Parameters

| Name                         | Type     | Required | Description                                                         |
| :--------------------------- | :------: | :------: | :------------------------------------------------------------------ |
| `name`                       | `string` | Yes      | The resource name.                                                  |
| `location`                   | `string` | Yes      | The geo-location where the resource lives.                          |
| `tags`                       | `object` | No       | Optional. Resource tags.                                            |
| `virtualNetworkResourceName` | `string` | Yes      | Existing virtual network name to create the DNS Resolver in.        |
| `inboundSubnetName`          | `string` | No       | Optional. Existing subnet name for inbound DNS requests.            |
| `outboundSubnetName`         | `string` | No       | Optional. Existing subnet name for outbound DNS requests.           |
| `resourceLock`               | `string` | No       | Optional. Specify the type of resource lock.                        |
| `enableDefaultTelemetry`     | `bool`   | No       | Optional. Enable telemetry via a Globally Unique Identifier (GUID). |

## Outputs

| Name       | Type   | Description                                       |
| :--------- | :----: | :------------------------------------------------ |
| name       | string | The name of the deployed private dns zone.        |
| resourceid | string | The resource ID of the deployed private dns zone. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.