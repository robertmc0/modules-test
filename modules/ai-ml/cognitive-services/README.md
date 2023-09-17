# Azure Cognitive Service

Deploys Azure Cognitive Service Account, including deployments as required.

## Details

This module completes the following tasks:

- Creates an Azure Cognitive Service account
- Creates deployments within the account for specified AI services

## Parameters

| Name                  | Type     | Required | Description                                                                  |
| :-------------------- | :------: | :------: | :--------------------------------------------------------------------------- |
| `name`                | `string` | Yes      | The name of the Cognitive Service Account.                                   |
| `kind`                | `string` | No       | The kind Cognitive Service resource being created.                           |
| `sku`                 | `string` | No       | The SKU used for your Cognitive Service.                                     |
| `location`            | `string` | No       | Optional. The location of the Cognitive Service Account.                     |
| `tags`                | `object` | No       | Optional. Resource tags.                                                     |
| `customSubDomainName` | `string` | No       | Optional. The publicly visible subdomain for your Cognitive Service.         |
| `deployments`         | `array`  | No       | Optional. Deployments for use when creating OpenAI Resources.                |
| `publicNetworkAccess` | `string` | No       | Optional. Whether or not public endpoint access is allowed for this account. |
| `properties`          | `object` | No       | Optional. The properties to be used for each individual cognitive service.   |

## Outputs

| Name       | Type     | Description                                                 |
| :--------- | :------: | :---------------------------------------------------------- |
| `endpoint` | `string` | The endpoint (subdomain) of the deployed Cognitive Service. |
| `id`       | `string` | The resource ID of the deployed Cognitive Service.          |
| `name`     | `string` | The name of the deployed Cognitive Service.                 |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.