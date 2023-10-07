# Azure Search Service

Deploys Azure Search Service Account.

## Details

This module completes the following tasks:

- Creates an Azure Search Service account
- Enables resource locks as required
- Enables diagnostics as required

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The name of the Search Service Account.                                                                                                                    |
| `location`                              | `string` | No       | Optional. The location of the Cognitive Service Account.                                                                                                   |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                   |
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