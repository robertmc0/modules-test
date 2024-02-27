# Private Endpoints Module

This module deploys Microsoft.Network privateEndpoints.

## Description

This module performs the following

- Creates Microsoft.Network privateEndpoints resource.
- Associates the private endpoint with the given single Private DNS Zone. **
- Applies a lock to the private endpoint if the lock is specified.

**NOTE:** ** Registering the resource with multiple private DNS zones should be done by creating multiple private-endpoints per DNS zone to be registered. This will also allow the segregation of traffic via firewall or nsg.

## Parameters

| Name                      | Type     | Required | Description                                                                                        |
| :------------------------ | :------: | :------: | :------------------------------------------------------------------------------------------------- |
| `targetResourceName`      | `string` | Yes      | Name of the target resource for which to create the Private Endpoint.                              |
| `targetResourceId`        | `string` | Yes      | Resource Id of the target resource for which to create the Private Endpoint.                       |
| `targetSubResourceType`   | `string` | Yes      | The type of sub-resource for the target resource that the private endpoint will be able to access. |
| `location`                | `string` | Yes      | Location of the resource.                                                                          |
| `subnetId`                | `string` | Yes      | Resource ID of the subnet that will host the Private Endpoint.                                     |
| `privateDnsZoneId`        | `string` | No       | Optional. Resource ID of the Private DNS Zone to host the Private Endpoint.                        |
| `privateDNSZoneGroupName` | `string` | No       | Optional. Private endpoint DNS Group Name. Defaults to default.                                    |
| `resourcelock`            | `string` | No       | Optional. Specify the type of resource lock.                                                       |

## Outputs

| Name                 | Type     | Description                                |
| :------------------- | :------: | :----------------------------------------- |
| `name`               | `string` | The name of the private endpoint.          |
| `resourceId`         | `string` | The resource ID of the private endpoint.   |
| `ipAddress`          | `string` | The private endpoint IP address.           |
| `ipAllocationMethod` | `string` | The private endpoint IP allocation method. |

## Examples

See [Tests File](test/main.test.bicep)