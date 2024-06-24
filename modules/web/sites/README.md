# TODO: App Service Web Sites

TODO: This module deploys Microsoft.web/sites AKA App Service Web Sites

## Details

This module completes the following tasks:

- Creates a Microsoft.web/sites resource
- Connects Application Insights if specified
- Enables CORS if specified
- Provides options to deploy Windows or Linux
- Applies a lock to the component if specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | Name of App Service Plan                                                                                                                                                |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                                                |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                                                            |
| `serverFarmId`                          | `string` | Yes      | Resource ID of the App Service Plan                                                                                                                                     |
| `virtualNetworkSubnetId`                | `string` | Yes      | The resource ID for the target virtual network subnet.                                                                                                                  |
| `apiManagementConfig`                   | `string` | No       | Optional. Azure API management settings linked to the app.                                                                                                              |
| `appInsightsInstrumentationKey`         | `string` | No       | Instrumentation key for Application Insights.                                                                                                                           |
| `appInsightsConnectionString`           | `string` | No       | Connection string for Application Insights.                                                                                                                             |
| `isLinux`                               | `bool`   | Yes      | Required. Set to true when using Linux such as for Node runtimes, or false for Windows.                                                                                 |
| `linuxFxVersion`                        | `string` | No       | Required when isLinux is true. The version of the runtime stack to use i.e NODE|20-lts.                                                                                 |
| `dotnetVersion`                         | `string` | No       | Required when isLinux is false. The .NET version to use i.e 8.0.                                                                                                        |
| `allowedOrigins`                        | `array`  | Yes      | Gets or sets the list of origins that should be allowed to make cross-origin calls (for example: http://example.com:12345).                                             |
| `supportCredentials`                    | `bool`   | Yes      | Gets or sets whether CORS requests with credentials are allowed. See https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Requests_with_credentials for more details. |
| `appSettings`                           | `array`  | No       | Optional. Application Insights configuration for the app service sites.                                                                                                 |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                                    |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                                                 |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                                            |

## Outputs

| Name         | Type     | Description                                         |
| :----------- | :------: | :-------------------------------------------------- |
| `name`       | `string` | The name of the web sites resource.                 |
| `resourceId` | `string` | The resource ID of the deployed web sites resource. |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```