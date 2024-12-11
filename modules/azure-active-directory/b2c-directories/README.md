# Entra B2C Module

This module deploys an Entra B2C (Microsoft.AzureActiveDirectory/b2cDirectories) resource.

## Details

This module deploys an Entra B2C (Microsoft.AzureActiveDirectory/b2cDirectories) resource. Microsoft Entra was previously Azure Active Directory and this module refers to a tenant as a directory but the terms are interchangeable. Read more at https://learn.microsoft.com/en-us/azure/active-directory-b2c/.

## Parameters

| Name          | Type     | Required | Description                                                                                                                        |
| :------------ | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------- |
| `tenantName`  | `string` | Yes      | Name of the B2C Tenant                                                                                                             |
| `displayName` | `string` | Yes      | The display name for the Entra B2C Directory.                                                                                      |
| `location`    | `string` | Yes      | The location where the Entra B2C Directory will be deployed.                                                                       |
| `skuName`     | `string` | No       | Optional. The name of the SKU for the Entra B2C Directory.                                                                         |
| `skuTier`     | `string` | No       | Optional. The tier of the SKU for the Entra B2C Directory.                                                                         |
| `countryCode` | `string` | Yes      | The country code for the tenant. See https://learn.microsoft.com/en-us/azure/active-directory-b2c/data-residency for more details. |
| `tags`        | `object` | No       | Optional. Resource tags.                                                                                                           |

## Outputs

| Name                | Type     | Description                                      |
| :------------------ | :------: | :----------------------------------------------- |
| `directoryId`       | `string` | The resource ID of the created Entra B2C Tenant. |
| `directoryLocation` | `string` | The location of the created Entra B2C Tenant.    |
| `tenantId`          | `string` | The tenant ID of the created Entra B2C Tenant.   |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.