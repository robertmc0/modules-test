# Container Apps Managed environment

This module deploys Microsoft App Managed Environments

## Details

- Creates Microsoft.App managed environment resource.
- Enables peer encryption if specified.
- Enables Zone Redundancy settings if specified.
- Integrates virtual network if specified.
- Enables resource locks if specified.
- Disables public network access if specified.
- Enables mutual TLS if specified.
- Enables logging to log analytics workspace if specified.
- Enabled logging to application insights if specified.
- Customises DNS suffix if specified.

## Parameters

| Name                          | Type     | Required | Description                                                                                                                                                                                                                        |
| :---------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                        | `string` | Yes      | The resource name.                                                                                                                                                                                                                 |
| `location`                    | `string` | Yes      | The geo-location where the resource lives.                                                                                                                                                                                         |
| `tags`                        | `object` | No       | Optional. Resource tags.                                                                                                                                                                                                           |
| `mtlsEnabled`                 | `bool`   | No       | Optional. Enable mutual TLS.                                                                                                                                                                                                       |
| `peerEncryptionEnabled`       | `bool`   | No       | Optional. Enable peer traffic encryption.                                                                                                                                                                                          |
| `isZoneRedundant`             | `bool`   | No       | Optional. Enable zone redundancy.                                                                                                                                                                                                  |
| `vnetConfiguration`           | `object` | No       | Optional. Name of the Application Insights resource.                                                                                                                                                                               |
| `applicationInsights`         | `object` | No       | Optional. Application Insights resource for DAPR logs.                                                                                                                                                                             |
| `logAnalyticsConfiguration`   | `object` | No       | Optional. Log analytics resource for DAPR logs.                                                                                                                                                                                    |
| `publicNetworkAccess`         | `string` | No       | Optional. Allow or block all public traffic.                                                                                                                                                                                       |
| `infrastructureResourceGroup` | `string` | No       | Optional. Name of the platform-managed resource group created for the Managed Environment to host infrastructure resources.If a subnet ID is provided, this resource group will be created in the same subscription as the subnet. |
| `dnsSuffix`                   | `string` | No       | Optional. DNS suffix for the environment domain.                                                                                                                                                                                   |
| `resourceLock`                | `string` | No       | Optional. Specify the type of resource lock.                                                                                                                                                                                       |

## Outputs

| Name                     | Type     | Description                                          |
| :----------------------- | :------: | :--------------------------------------------------- |
| `managedEnvironmentName` | `string` | Name of the the deployed managed environment.        |
| `managedEnvironmentId`   | `string` | The resource ID of the deployed managed environment. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.