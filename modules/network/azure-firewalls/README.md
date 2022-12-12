# Azure Firewalls Module

This module deploys Microsoft.Network azureFirewalls

## Description

This module performs the following

- Creates Microsoft.Network azureFirewalls resource.
- Enables forced tunneling if specified.
- Enables DNS proxy with customer DNS servers on firewall if specified.
- Applies diagnostic settings.
- Applies a lock to the bastion host if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                             |
| :-------------------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                      |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                              |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                |
| `tier`                                  | `string` | Yes      | Tier of an Azure Firewall.                                                                                              |
| `sku`                                   | `string` | No       | Optional. The Azure Firewall Resource SKU. Set to AZFW_Hub only if attaching to a Virtual Hub.                          |
| `subnetResourceId`                      | `string` | No       | Optional. Resource ID of the Azure firewall subnet.                                                                     |
| `publicIpAddressName`                   | `string` | No       | Optional. Name of the Azure firewall public IP address.                                                                 |
| `firewallManagementConfiguration`       | `object` | No       | Optional. IP configuration of the Azure Firewall used for management traffic.                                           |
| `policyName`                            | `string` | Yes      | Firewall policy name.                                                                                                   |
| `threatIntelMode`                       | `string` | No       | Optional. The operation mode for Threat Intelligence.                                                                   |
| `enableDnsProxy`                        | `bool`   | No       | Optional. Enable DNS Proxy on Firewalls attached to the Firewall Policy.                                                |
| `customDnsServers`                      | `array`  | No       | Optional. List of Custom DNS Servers. Only required when enableDnsProxy set to true.                                    |
| `availabilityZones`                     | `array`  | No       | Optional. A list of availability zones denoting where the resource should be deployed.                                  |
| `virtualHubResourceId`                  | `string` | No       | Optional. Resource ID of the Azure virtual hub.                                                                         |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                    |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                        |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                    |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.          |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                               |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                       |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true. |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                            |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                            |

## Outputs

| Name             | Type   | Description                                        |
| :--------------- | :----: | :------------------------------------------------- |
| name             | string | The name of the deployed Azure firewall.           |
| resourceId       | string | The resource ID of the deployed Azure firewall.    |
| privateIpAddress | string | Private IP address of the deployed Azure firewall. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.