# Azure Databricks Access Connector

Deploys Azure Databricks access connector, enabling connectivity to ADLS & other resources using Managed Identity

## Description

{{ Add detailed description for the module. }}

## Parameters

| Name                     | Type     | Required | Description                                                         |
| :----------------------- | :------: | :------: | :------------------------------------------------------------------ |
| `name`                   | `string` | Yes      | The resource name.                                                  |
| `location`               | `string` | Yes      | The geo-location where the resource lives.                          |
| `tags`                   | `object` | No       | Optional. Resource tags.                                            |
| `systemAssignedIdentity` | `bool`   | No       | Optional. Enables system assigned managed identity on the resource. |
| `resourceLock`           | `string` | No       | Optional. Specify the type of resource lock.                        |

## Outputs

| Name                      | Type   | Description                                       |
| :------------------------ | :----: | :------------------------------------------------ |
| name                      | string | The name of the deployed access connector.        |
| resourceId                | string | The resource ID of the deployed access connector. |
| systemAssignedPrincipalId | string | The principal ID of the system assigned identity. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.