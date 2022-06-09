# Private Endpoints Module

This module deploys Microsoft.Network privateEndpoints and associates with the given Private DNS Zone

## Parameters

| Name                 | Type     | Required | Description                                                          |
| :------------------- | :------: | :------: | :------------------------------------------------------------------- |
| `targetResourceName` | `string` | Yes      | Name of the Resource for which to create the Private Endpoint        |
| `targetResourceId`   | `string` | Yes      | Resource Id of the Resource for which to create the Private Endpoint |
| `type`               | `string` | Yes      | Private Endpoint types                                               |
| `location`           | `string` | Yes      | Location of the resource.                                            |
| `subnetId`           | `string` | Yes      | Resource ID of the subnet that will host Private Endpoint.           |
| `privateDnsZoneId`   | `string` | Yes      | Resource ID of the Private DNS Zone to host Private Endpoint entry.  |
| `lock`               | `string` | No       | Optional. Specify the type of lock.                                  |

## Outputs

| Name               | Type   | Description                               |
| :----------------- | :----: | :---------------------------------------- |
| name               | string | The name of the private endpoint          |
| id                 | string | The resource ID of the private endpoint   |
| ipAddress          | string | The private endpoint IP address           |
| ipAllocationMethod | string | The private endpoint IP allocation method |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```