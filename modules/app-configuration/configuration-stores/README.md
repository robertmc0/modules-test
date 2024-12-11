# App Configuration Module

This module deploys App Configuration resource.

## Details

This module deploys an Azure App Configuration resource (`Microsoft.AppConfiguration/configurationStores`).

> Azure App Configuration provides a service to centrally manage application settings and feature flags. Modern programs, especially programs running in a cloud, generally have many components that are distributed in nature. Spreading configuration settings across these components can lead to hard-to-troubleshoot errors during an application deployment. Use App Configuration to store all the settings for your application and secure their accesses in one place.

This module also includes replica settings, a lock setting and diagnostic setting for use with Azure Monitor.

Read more at

- https://learn.microsoft.com/en-us/azure/azure-app-configuration/overview
- https://learn.microsoft.com/en-us/azure/templates/microsoft.appconfiguration/configurationstores?pivots=deployment-language-bicep

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `name`                                  | `string` | Yes      | The name of the resource.                                                                                               |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `replicas`                              | `array`  | No       | Optional. A list of App Configuration Replica settings.                                                                 |

## Outputs

| Name         | Type     | Description                               |
| :----------- | :------: | :---------------------------------------- |
| `name`       | `string` | The name of the deployed resource.        |
| `resourceId` | `string` | The resource ID of the deployed resource. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.