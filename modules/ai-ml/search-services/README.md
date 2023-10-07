# Azure Search Service

Deploys Azure Search Service Account.

## Details

This module completes the following tasks:

- Creates an Azure Search Service account
- Enables resource locks as required
- Enables diagnostics as required

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                                                                                   |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The name of the Search Service Account.                                                                                                                                                                                       |
| `location`                              | `string` | No       | Optional. The location of the Search Service Account.                                                                                                                                                                         |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                                                                                      |
| `sku`                                   | `string` | No       | Optional. The Sku of the Search Service Account.                                                                                                                                                                              |
| `hostingMode`                           | `string` | No       | Optional. The hosting mode of the Search Service Account. highDensity is only available for standard3 SKUs.                                                                                                                   |
| `replicaCount`                          | `int`    | No       | Optional. The number of replicas in the Search Service Account.  If specified, it must be a value between 1 and 12 inclusive for standard SKUs or between 1 and 3 inclusive for basic SKU.                                    |
| `partitionCount`                        | `int`    | No       | Optional. The number of partitions in the Search Service Account. Values greater than 1 are only valid for standard SKUs. For standard3 services with hostingMode set to highDensity, the allowed values are between 1 and 3. |
| `semanticSearch`                        | `string` | No       | Optional. Enable/Disable semantic search.                                                                                                                                                                                     |
| `publicNetworkAccess`                   | `string` | No       | Optional. Enable/Disable public acccess.                                                                                                                                                                                      |
| `authOptions`                           | `object` | No       | Optional. The auth options of the Search Service Account.                                                                                                                                                                     |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                                                                                                           |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                                                                                                                |
| `disabledDataExfiltrationOptions`       | `string` | No       | Optional. The data exfiltration options for the Search Service Account. Currently not able to be modified, param added for future service update.                                                                             |
| `allowedIpRanges`                       | `array`  | No       | Optional. Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed.                                                                                                                                          |
| `networkRuleSetDefaultAction`           | `string` | No       | Optional. The default action of allow or deny when no other rules match.                                                                                                                                                      |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                                                                                          |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                                                                                              |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                                                                                          |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Resource ID of the diagnostic log analytics workspace.                                                                                                                                                              |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.                                                                    |
| `diagnosticEventHubName`                | `string` | No       | Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.                                                                      |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Resource ID of the diagnostic storage account.                                                                                                                                                                      |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of lock.                                                                                                                                                                                           |

## Outputs

| Name         | Type     | Description                                     |
| :----------- | :------: | :---------------------------------------------- |
| `resourceId` | `string` | The resource ID of the deployed Search Service. |
| `name`       | `string` | The name of the deployed Search Service.        |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.