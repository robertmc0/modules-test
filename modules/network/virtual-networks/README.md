# Virtual Networks Module

This module deploys Microsoft.Network virtualNetworks.

## Description

This module performs the following

- Creates Microsoft.Network virtualNetworks resource.
- Applies custom DNS servers if specified.
- Associates subnet(s) to Network Security Group if specified.
- Associates subnet(s) to Route Table if specified.
- Associates subnet(s) to NAT Gateway if specified.
- Applies private endpoint policies to subnet(s).
- Applies delegation to subnet(s).
- Applies service endpoints to subnet(s).
- Applies diagnostic settings.
- Applies a lock to the virtual network if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `addressPrefixes`                       | `array`  | Yes      | The address space that contains an array of IP address ranges that can be used by subnets.                              |
| `dnsServers`                            | `array`  | No       | Optional. DNS servers associated to the virtual network. Leave blank if using Azure DNS.                                |
| `subnets`                               | `array`  | Yes      | A list of subnets associated to the virtual network.                                                                    |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.          |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |

## Outputs

| Name       | Type   | Description                                        |
| :--------- | :----: | :------------------------------------------------- |
| name       | string | The name of the deployed virtual network.          |
| resourceId | string | The resource ID of the deployed virtual network.   |
| subnets    | array  | List of subnets associated to the virtual network. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.