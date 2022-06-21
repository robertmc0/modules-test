# Private Endpoints Module

This module deploys Microsoft.Network privateEndpoints.

## Description

This module performs the following

- Creates Microsoft.Network privateEndpoints resource.
- Associates the private endpoint with the given Private DNS Zone.
- Applys a lock to the private endpoint if the lock is specified.

## Parameters

| Name                 | Type     | Required | Description                                                           |
| :------------------- | :------: | :------: | :-------------------------------------------------------------------- |
| `targetResourceName` | `string` | Yes      | Name of the Resource for which to create the Private Endpoint.        |
| `targetResourceId`   | `string` | Yes      | Resource Id of the Resource for which to create the Private Endpoint. |
| `type`               | `string` | Yes      | Private Endpoint type.                                                |
| `location`           | `string` | Yes      | Location of the resource.                                             |
| `subnetId`           | `string` | Yes      | Resource ID of the subnet that will host the Private Endpoint.        |
| `privateDnsZoneId`   | `string` | Yes      | Resource ID of the Private DNS Zone to host the Private Endpoint.     |
| `lock`               | `string` | No       | Optional. Specify the type of lock.                                   |

## Outputs

| Name               | Type   | Description                                |
| :----------------- | :----: | :----------------------------------------- |
| name               | string | The name of the private endpoint.          |
| resourceId         | string | The resource ID of the private endpoint.   |
| ipAddress          | string | The private endpoint IP address.           |
| ipAllocationMethod | string | The private endpoint IP allocation method. |

## Examples

See [Tests File](test/main.test.bicep)