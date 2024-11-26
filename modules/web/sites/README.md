# App Service Web Sites

This module deploys Microsoft.web/sites AKA App Service Web Sites

## Details

This module completes the following tasks:

- Creates a Microsoft.web/sites resource.
- Connects Application Insights if specified.
- Enables CORS if specified.
- Enables IP Restrictions if specified.
- Provides options to deploy Windows or Linux.
- Configures diagnostic settings if enabled.
- Applies a lock to the component if specified.

## Parameters

| Name                                     | Type     | Required | Description                                                                                                                                                                       |
| :--------------------------------------- | :------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                   | `string` | Yes      | Name of App Service Plan                                                                                                                                                          |
| `location`                               | `string` | Yes      | The geo-location where the resource lives.                                                                                                                                        |
| `tags`                                   | `object` | No       | Optional. Resource tags.                                                                                                                                                          |
| `kind`                                   | `string` | Yes      | Kind of web site.                                                                                                                                                                 |
| `resourceLock`                           | `string` | No       | Optional. Specify the type of resource lock.                                                                                                                                      |
| `serverFarmId`                           | `string` | Yes      | Resource ID of the App Service Plan                                                                                                                                               |
| `redundancyMode`                         | `string` | No       | Optional. Site redundancy mode.                                                                                                                                                   |
| `virtualNetworkSubnetId`                 | `string` | No       | Optional. The resource ID for the target virtual network subnet.                                                                                                                  |
| `vnetRouteAllEnabled`                    | `bool`   | No       | Optional. Virtual Network Route All enabled. This causes all outbound traffic to have Virtual Network Security Groups and User Defined Routes applied.                            |
| `publicNetworkAccess`                    | `bool`   | No       | Optional. Allow or block all public traffic.                                                                                                                                      |
| `keyVaultReferenceIdentity`              | `string` | No       | Optional. Identity to use for Key Vault Reference authentication.                                                                                                                 |
| `apiManagementConfig`                    | `string` | No       | Optional. Azure API management settings linked to the app.                                                                                                                        |
| `applicationInsightsId`                  | `string` | Yes      | Resource ID of the application insights resource.                                                                                                                                 |
| `runtime`                                | `string` | No       | Optional. Runtime type and version in the format TYPE|VERSION. Defaults to DOTNET|8.0                                                                                             |
| `allowedOrigins`                         | `array`  | No       | Optional. Gets or sets the list of origins that should be allowed to make cross-origin calls (for example: http://example.com:12345).                                             |
| `ipSecurityRestrictions`                 | `array`  | No       | Optional. IP security restrictions for main.                                                                                                                                      |
| `ipSecurityRestrictionsDefaultAction`    | `string` | No       | Optional. Default action for main access restriction if no rules are matched.                                                                                                     |
| `scmIpSecurityRestrictions`              | `array`  | No       | Optional. IP security restrictions for scm.                                                                                                                                       |
| `scmIpSecurityRestrictionsDefaultAction` | `string` | No       | Optional. Default action for scm access restriction if no rules are matched.                                                                                                      |
| `scmIpSecurityRestrictionsUseMain`       | `bool`   | No       | Optional. IP security restrictions for scm to use main.                                                                                                                           |
| `supportCredentials`                     | `bool`   | No       | Optional. Gets or sets whether CORS requests with credentials are allowed. See https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS#Requests_with_credentials for more details. |
| `alwaysOn`                               | `bool`   | No       | Optional. Determines if instances of thhe site are always running, even when idle.                                                                                                |
| `clientAffinityEnabled`                  | `bool`   | No       | Optional. Enable sending session affinity cookies, which route client requests in the same session to the same instance.                                                          |
| `appSettings`                            | `object` | No       | Optional. Application settings to be applied to web site.                                                                                                                         |
| `connectionStrings`                      | `array`  | No       | Optional. Array of Connection Strings.                                                                                                                                            |
| `functionsExtensionVersion`              | `string` | No       | Optional. The version of the Functions runtime that hosts your function app.                                                                                                      |
| `systemAssignedIdentity`                 | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                                                               |
| `userAssignedIdentities`                 | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                                                                    |
| `enableDiagnostics`                      | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                                                              |
| `diagnosticLogCategoryGroupsToEnable`    | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                                                                  |
| `diagnosticMetricsToEnable`              | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                                                              |
| `diagnosticStorageAccountId`             | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                                                         |
| `diagnosticLogAnalyticsWorkspaceId`      | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                                                 |
| `diagnosticEventHubAuthorizationRuleId`  | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                                                           |
| `diagnosticEventHubName`                 | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                                                      |
| `deploymentSlotNames`                    | `array`  | No       | Optional. Names of the deployment slots.                                                                                                                                          |

## Outputs

| Name         | Type     | Description                                         |
| :----------- | :------: | :-------------------------------------------------- |
| `name`       | `string` | The name of the web sites resource.                 |
| `resourceId` | `string` | The resource ID of the deployed web sites resource. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.