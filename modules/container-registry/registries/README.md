# Container Registry

This module deploys Microsoft.ContainerRegistry registry at the subscription level

## Details

- Creates Microsoft.ContainerRegistry registry resource.
- Enables the admin user if specified.
- Enables a single data endpoint per region for serving data if specified. Requires Premium sku.
- Enables encryption (CMK) settings of container registry if specified. Requires Premium sku.
- Enables Zone Redundancy settings of container registry if specified. Requires Premium sku.
- Disables public network access for the container registry if specified. Requires Premium sku.
- Enables trusted Azure services to access a network restricted registry if specified. Requires Premium sku.
- Applies network rules to access a network restricted registry if specified. Requires Premium sku.
- Applies a user assigned managed identity if specified.
- Applies diagnostic settings.
- Applies a lock to the key vault if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                  |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | Provide a globally unique name of your Azure Container Registry.                                                             |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                   |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                     |
| `sku`                                   | `string` | No       | Optional. The SKU name of the container registry.                                                                            |
| `adminUserEnabled`                      | `bool`   | No       | Optional. The value that indicates whether the admin user is enabled.                                                        |
| `dataEndpointEnabled`                   | `bool`   | No       | Optional. Enable a single data endpoint per region for serving data. Requires Premium sku.                                   |
| `encryptionEnabled`                     | `bool`   | No       | Optional. Enable encryption settings of container registry. Requires Premium sku.                                            |
| `userAssignedIdentity`                  | `string` | No       | Optional. The resource ID of the user assigned managed identity.                                                             |
| `userAssignedIdentityId`                | `string` | No       | Optional. The Client ID of the identity which will be used to access Key Vault.                                              |
| `keyVaultIdentifier`                    | `string` | No       | Optional. The Key Vault URI to access the encryption key. Requires Premium sku.                                              |
| `zoneRedundancy`                        | `bool`   | No       | Optional. Enable Zone Redundancy settings of container registry. Must be in a region that supports it. Requires Premium sku. |
| `allowNetworkRuleBypass`                | `bool`   | No       | Optional. Whether to allow trusted Azure services to access a network restricted registry.                                   |
| `disablePublicNetworkAccess`            | `bool`   | No       | Optional. Whether or not public network access is allowed for the container registry. Requires Premium sku.                  |
| `allowedIpRanges`                       | `array`  | No       | Optional. Specifies the IP or IP range in CIDR format. Only IPV4 address is allowed. Requires Premium sku.                   |
| `networkRuleSetDefaultAction`           | `string` | No       | Optional. The default action of allow or deny when no other rules match. Requires Premium sku.                               |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                 |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                         |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                             |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                         |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                    |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                            |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.      |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                 |

## Outputs

| Name          | Type     | Description                                              |
| :------------ | :------: | :------------------------------------------------------- |
| `name`        | `string` | The name of the deployed key vault.                      |
| `resourceId`  | `string` | The resource ID of the deployed key vault.               |
| `loginServer` | `string` | The login server URI of the deployed container registry. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.