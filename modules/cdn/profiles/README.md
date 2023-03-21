# 

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `frontDoorName`                         | `string` | Yes      | The name of the Front Door endpoint to create. This must be globally unique.                                            |
| `skuName`                               | `string` | Yes      | The name of the SKU to use when creating the Front Door profile.                                                        |
| `endpoints`                             | `array`  | Yes      | Endpoints to deploy to Frontdoor                                                                                        |
| `originGroups`                          | `array`  | Yes      | Origin Groups to deploy to Frontdoor                                                                                    |
| `origins`                               | `array`  | Yes      | Origins to deploy to Frontdoor                                                                                          |
| `secrets`                               | `array`  | No       | Certificates to deploy to Frontdoor                                                                                     |
| `customDomains`                         | `array`  | No       | Custom domains to deploy to Frontdoor                                                                                   |
| `routes`                                | `array`  | Yes      | Routes to deploy to Frontdoor                                                                                           |
| `securityPolicies`                      | `array`  | No       |                                                                                                                         |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                     |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                          |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.          |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |

## Outputs

| Name          | Type   | Description                                              |
| :------------ | :----: | :------------------------------------------------------- |
| name          | string | The name of the deployed Azure Frontdoor Profile.        |
| resourceId    | string | The resource Id of the deployed Azure Frontdoor Profile. |
| endpoints     | array  |                                                          |
| customDomains | array  |                                                          |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```