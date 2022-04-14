# Sql Server

This module deploys Microsoft.Sql servers and optionally databases

## Parameters

| Name                  | Type           | Required | Description                                                                                                    |
| :-------------------- | :------------: | :------: | :------------------------------------------------------------------------------------------------------------- |
| `sqlServerName`       | `string`       | Yes      | Name of the Azure SQL resource                                                                                 |
| `location`            | `string`       | No       | Location of the resource.                                                                                      |
| `sqlAdminLogin`       | `secureString` | Yes      | SQL Administrator credentials - Username                                                                       |
| `sqlAdminPassword`    | `secureString` | Yes      | SQL Administrator credentials - Password                                                                       |
| `aadAdminLogin`       | `string`       | Yes      | Name of the AAD User or Group to grant as SQL Admin via AAD.                                                   |
| `aadAdminObjectId`    | `string`       | Yes      | Object ID of the AAD User or Group to grant as SQL Admin via AAD.  Must be defined if aadAdminLogin defined.   |
| `publicNetworkAccess` | `string`       | No       | Enable/Disable Public Network Access. Only Disable if you wish to restrict to just private endpoints and VNET. |
| `connectionType`      | `string`       | No       | The server connection type. - Default, Proxy, Redirect.  Note private link requires Proxy.                     |
| `tags`                | `object`       | No       | Object containing resource tags.                                                                               |
| `enableResourceLock`  | `bool`         | No       | Enable a Can Not Delete Resource Lock.  Useful for production workloads.                                       |

## Outputs

| Name | Type   | Description                       |
| :--- | :----: | :-------------------------------- |
| name | string | The name of the sql server        |
| id   | string | The resource ID of the sql server |

## Examples

### Example 1

```bicep
module azureSqlServer 'br/ArincoModules:sql.servers:0.1.1' = {
  name: '${uniqueString(deployment().name, 'AustraliaEast')}-sqlserver'
  params: {
    sqlServerName: 'example-dev-sql'
    sqlAdminLogin: 'sqladmin'
    sqlAdminPassword: 'reallystrongpwd'
    enableResourceLock: false
    aadAdminLogin: 'sqladmin-group'
    aadAdminObjectId: 'xxxx-xxx-xxxx-xxx'
  }
}
```