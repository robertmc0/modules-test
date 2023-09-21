# Azure Cognitive Service

Deploys Azure Cognitive Service Account, including deployments as required.

## Details

This module completes the following tasks:

- Creates an Azure Cognitive Service account
- Creates deployments within the account for specified AI services

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The name of the Cognitive Service Account.                                                                                                                 |
| `kind`                                  | `string` | Yes      | The kind Cognitive Service resource being created.                                                                                                         |
| `sku`                                   | `string` | Yes      | The SKU used for your Cognitive Service.                                                                                                                   |
| `location`                              | `string` | No       | Optional. The location of the Cognitive Service Account.                                                                                                   |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                   |
| `customSubDomainName`                   | `string` | No       | Optional. The publicly visible subdomain for your Cognitive Service.                                                                                       |
| `deployments`                           | `array`  | No       | Optional. Deployments for use when creating OpenAI Resources.                                                                                              |
| `publicNetworkAccess`                   | `string` | No       | Optional. Whether or not public endpoint access is allowed for this account.                                                                               |
| `properties`                            | `object` | No       | Optional. The properties to be used for each individual cognitive service.                                                                                 |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                       |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                           |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                       |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Resource ID of the diagnostic log analytics workspace.                                                                                           |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.   |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Resource ID of the diagnostic storage account.                                                                                                   |
| `resourcelock`                          | `string` | No       | Optional. Specify the type of lock.                                                                                                                        |

## Outputs

| Name       | Type     | Description                                                 |
| :--------- | :------: | :---------------------------------------------------------- |
| `endpoint` | `string` | The endpoint (subdomain) of the deployed Cognitive Service. |
| `id`       | `string` | The resource ID of the deployed Cognitive Service.          |
| `name`     | `string` | The name of the deployed Cognitive Service.                 |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.