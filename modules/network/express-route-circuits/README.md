# Express Route Circuits Module

This module deploys Microsoft.Network expressRouteCircuits

## Description

This module performs the following

- Creates Microsoft.Network expressRouteCircuits resource.
- Applies Azure private peering if specified.
- Applies diagnostic settings.
- Applies a lock to the bastion host if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `tier`                                  | `string` | No       | Optional. The sku of this ExpressRoute circuit.                                                                         |
| `billingModel`                          | `string` | Yes      | The billing model of the ExpressRoute circuit.                                                                          |
| `allowClassicOperations`                | `bool`   | No       | Optional. Allow classic operations.                                                                                     |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `bandwidthInMbps`                       | `int`    | Yes      | The bandwidth of the ExpressRoute circuit.                                                                              |
| `peeringLocation`                       | `string` | Yes      | The peering location.                                                                                                   |
| `serviceProviderName`                   | `string` | Yes      | The service provider name.                                                                                              |
| `peeringConfig`                         | `object` | No       | Optional. Peering configuration object.                                                                                 |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.          |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |

## Outputs

| Name       | Type   | Description                                            |
| :--------- | :----: | :----------------------------------------------------- |
| name       | string | The name of the deployed express route circuit.        |
| resourceId | string | The resource ID of the deployed express route circuit. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.