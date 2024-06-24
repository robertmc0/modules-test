# App Service Sites

This module deploys Microsoft.web/sites aka App Service Web Apps

## Details

This module completes the following tasks:

- Creates a Microsoft.web/sites resource
- Connects Application Insights if specified
- Enables CORS if specified
- Provides options to deploy Windows or Linux
- Applies a lock to the component if specified.

## Parameters

| Name                           | Type    | Required | Description                                                                                   |
| :----------------------------- | :-----: | :------: | :-------------------------------------------------------------------------------------------- |
| `name`                         | string  | Yes      | Name of App Service Plan                                                                      |
| `location`                     | string  | Yes      | The geo-location where the resource lives.                                                    |
| `tags`                         | object  | No       | Optional. Resource tags.                                                                      |
| `resourceLock`                 | string  | No       | Optional. Specify the type of resource lock. Allowed values: CanNotDelete, NotSpecified, ReadOnly |
| `serverFarmId`                 | string  | Yes      | Resource ID of the App Service Plan                                                           |
| `virtualNetworkSubnetId`       | string  | Yes      | The resource ID for the target virtual network subnet.                                        |
| `apiManagementConfig`          | string  | No       | Optional. Azure API management settings linked to the app.                                    |
| `appInsightsInstrumentationKey`| string  | No       | Instrumentation key for Application Insights.                                                 |
| `appInsightsConnectionString`  | string  | No       | Connection string for Application Insights.                                                   |
| `isLinux`                      | bool    | Yes      | Required. Set to true when using Linux such as for Node runtimes, or false for Windows.       |
| `linuxFxVersion`               | string  | No       | Required when isLinux is true. The version of the runtime stack to use i.e NODE\|20-lts.      |
| `dotnetVersion`                | string  | No       | Required when isLinux is false. The .NET version to use i.e 8.0.                              |
| `allowedOrigins`               | array   | Yes      | Gets or sets the list of origins that should be allowed to make cross-origin calls.           |
| `supportCredentials`           | bool    | Yes      | Gets or sets whether CORS requests with credentials are allowed.                              |

## Outputs

| Name         | Type     | Description                                                |
| :----------- | :------: | :--------------------------------------------------------- |
| `name`       | `string` | The name of the web sites resource.                        |
| `resourceId` | `string` | The resource ID of the deployed web sites resource.        |

## Examples

### Example 1

```bicep
```

### Example 2

```bicep
```