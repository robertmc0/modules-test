# Application Gateways Module

This module deploys Microsoft.Network applicationGateways

## Details

This module performs the following

- Creates Microsoft.Network applicationGateways resource.
- Enables web application firewall if specified.
- Add existing firewall policy if specified.
- Add SSL/Trusted Root certificates from key vault to application gateway.
- Add custom probes.
- Add custom backend settings and redirect configurations.
- Applies diagnostic settings.
- Applies a lock to the application gateway if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                                 |
| :-------------------------------------- | :------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------ |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                          |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                                  |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                                    |
| `tier`                                  | `string` | Yes      | Tier of an application gateway.                                                                                                             |
| `sku`                                   | `string` | Yes      | Name of an application gateway SKU.                                                                                                         |
| `autoScaleMinCapacity`                  | `int`    | No       | Optional. Autoscale minimum capacity on application gateway resource.                                                                       |
| `autoScaleMaxCapacity`                  | `int`    | No       | Optional. Autoscale maximum capacity on application gateway resource.                                                                       |
| `http2Enabled`                          | `bool`   | No       | Optional. Whether HTTP2 is enabled on the application gateway resource.                                                                     |
| `publicIpAddressName`                   | `string` | Yes      | Name of the application gateway public IP address.                                                                                          |
| `subnetResourceId`                      | `string` | Yes      | Resource ID of the application gateway subnet.                                                                                              |
| `sslCertificates`                       | `array`  | No       | Optional. SSL certificates of the application gateway resource.                                                                             |
| `sslPolicy`                             | `object` | No       | Optional. SSL policy of the application gateway resource.                                                                                   |
| `trustedRootCertificates`               | `array`  | No       | Optional. Trusted root certificates of the application gateway resource.                                                                    |
| `httpListeners`                         | `array`  | Yes      | Http listeners of the application gateway resource.                                                                                         |
| `backendAddressPools`                   | `array`  | No       | Optional. Backend address pool of the application gateway resource.                                                                         |
| `backendHttpSettings`                   | `array`  | No       | Optional. Backend http settings of the application gateway resource.                                                                        |
| `requestRoutingRules`                   | `array`  | Yes      | Request routing rules of the application gateway resource.                                                                                  |
| `redirectConfigurations`                | `array`  | No       | Optional. Redirect configurations of the application gateway resource.                                                                      |
| `frontEndPorts`                         | `array`  | Yes      | Frontend ports of the application gateway resource.                                                                                         |
| `frontEndPrivateIpAddress`              | `string` | No       | Optional. Frontend private IP address for application gateway resource. IP address must be based on the supplied subnet supported IP range. |
| `probes`                                | `array`  | No       | Optional. Probes of the application gateway resource.                                                                                       |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                         |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                              |
| `webApplicationFirewallConfig`          | `object` | No       | Optional. Web application firewall configuration.                                                                                           |
| `firewallPolicyId`                      | `string` | No       | Optional. Resource ID of the firewall policy.                                                                                               |
| `availabilityZones`                     | `array`  | No       | Optional. A list of availability zones denoting where the resource should be deployed.                                                      |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                                        |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                            |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                                        |
| `diagnosticLogsRetentionInDays`         | `int`    | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                              |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                   |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                           |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                     |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                                |

## Outputs

| Name         | Type     | Description                                          |
| :----------- | :------: | :--------------------------------------------------- |
| `name`       | `string` | The name of the deployed application gateway.        |
| `resourceId` | `string` | The resource ID of the deployed application gateway. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.