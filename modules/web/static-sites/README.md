# Static Web App

This module deploys a Static Web App (Microsoft.Web/staticSites)

## Details

This module deploys a Static Web App (Microsoft.Web/staticSites) and a resource lock.

## Parameters

| Name           | Type     | Required | Description                                  |
| :------------- | :------: | :------: | :------------------------------------------- |
| `location`     | `string` | Yes      | The geo-location where the resource lives.   |
| `name`         | `string` | Yes      | Name of Static Web App.                      |
| `sku`          | `string` | No       | Optional. Name of the  Static Web App SKU.   |
| `tags`         | `object` | No       | Optional. Resource tags.                     |
| `resourceLock` | `string` | No       | Optional. Specify the type of resource lock. |

## Outputs

| Name         | Type     | Description                               |
| :----------- | :------: | :---------------------------------------- |
| `name`       | `string` | The name of the deployed resource.        |
| `resourceId` | `string` | The resource ID of the deployed resource. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.