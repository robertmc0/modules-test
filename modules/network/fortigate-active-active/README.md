# FortiGate Active Active Module

This module deploys a FortiGate Network Virtual Appliance with an active-active architecture

## Details

This module deploys a FortiGate Network Virtual Appliance with an active-active architecture as documented [here](https://github.com/fortinet/azure-templates/tree/main/FortiGate/Active-Active-ELB-ILB).
The FortiGate Network Virtual Appliance is deployed with:

- Two network interfaces, one for the external (untrusted) subnet and one for the internal (trusted) subnet.
- A public load balancer for the external traffic load balanced between both appliances.
- An internal load balancer for the internal traffic load balanced between both appliances.
- A network security group associated to each network interface to ensure traffic flow.
- Two FortiGate Network Virtual Appliances are deployed to provide an active-active architecture.
- Optionally configure diagnostic settings.
- Optionally enables resource locks on the required resources.

The deployment integrates into an existing virtual network and the resources deployed will consume the last available IP addresses in the external and internal subnets.

> Note: You will need to accept the legal terms before you can deploy this module. Terms can be accepted by running this command: Set-AzMarketplaceTerms -Name fortinet_fg-vm -Product fortinet_fortigate-vm_v5 -Publisher fortinet -Accept

## Parameters

| Name                                    | Type           | Required | Description                                                                                                                                                                                                                       |
| :-------------------------------------- | :------------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `namePrefix`                            | `string`       | Yes      | Specifies the name prefix for the FortiGate resources.                                                                                                                                                                            |
| `location`                              | `string`       | Yes      | The geo-location where the resource lives.                                                                                                                                                                                        |
| `tags`                                  | `object`       | No       | Optional. Resource tags.                                                                                                                                                                                                          |
| `imageVersion`                          | `string`       | No       | Optional. FortiGate image version. Only required when PAYG sku is selected.                                                                                                                                                       |
| `size`                                  | `string`       | No       | Optional. Specifies the size of the virtual machine. Refer to https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#hardwareprofile for values.                    |
| `adminUsername`                         | `string`       | Yes      | Specifies the name of the administrator account.                                                                                                                                                                                  |
| `adminPassword`                         | `securestring` | Yes      | Specifies the password of the administrator account. Refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#osprofile for password complexity requirements. |
| `availabilityZones`                     | `array`        | No       | Optional. A list of availability zones denoting the zone in which the virtual machine should be deployed.                                                                                                                         |
| `availabilitySetConfiguration`          | `object`       | No       | Optional. The availability set configuration for the virtual machine. Not required if availabilityZones is set.                                                                                                                   |
| `externalLoadBalancerName`              | `string`       | Yes      | The external (public) load balancer name.                                                                                                                                                                                         |
| `externalLoadBalancerPublicIpName`      | `string`       | Yes      | The external (public) load balancer public IP name.                                                                                                                                                                               |
| `internalLoadBalancerName`              | `string`       | Yes      | The internal (private) load balancer name.                                                                                                                                                                                        |
| `nsgName`                               | `string`       | Yes      | The name of the network security group assoicated to the network interfaces.                                                                                                                                                      |
| `externalSubnetId`                      | `string`       | Yes      | Subnet ID for the external (untrust) subnet.                                                                                                                                                                                      |
| `internalSubnetId`                      | `string`       | Yes      | Subnet ID for the internal (trust) subnet.                                                                                                                                                                                        |
| `acceleratedNetworking`                 | `bool`         | No       | Optional. Enable accelerated networking on network interfaces.                                                                                                                                                                    |
| `enableDiagnostics`                     | `bool`         | No       | Optional. Enable diagnostic logging.                                                                                                                                                                                              |
| `diagnosticLogCategoryGroupsToEnable`   | `array`        | No       | Optional. The name of log category groups that will be streamed.                                                                                                                                                                  |
| `diagnosticMetricsToEnable`             | `array`        | No       | Optional. The name of metrics that will be streamed.                                                                                                                                                                              |
| `diagnosticLogsRetentionInDays`         | `int`          | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                                                                                                    |
| `diagnosticStorageAccountId`            | `string`       | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                                                                                                         |
| `diagnosticLogAnalyticsWorkspaceId`     | `string`       | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                                                                                                 |
| `diagnosticEventHubAuthorizationRuleId` | `string`       | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                                                                                                           |
| `diagnosticEventHubName`                | `string`       | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                                                                                                      |
| `resourceLock`                          | `string`       | No       | Optional. Specify the type of resource lock.                                                                                                                                                                                      |

## Outputs

| Name                   | Type     | Description                                                        |
| :--------------------- | :------: | :----------------------------------------------------------------- |
| `fortiGate1Name`       | `string` | The name of the first FortiGate Network Virtual Appliance.         |
| `fortiGate1ResourceId` | `string` | The resource ID of the first FortiGate Network Virtual Appliance.  |
| `fortiGate2Name`       | `string` | The name of the second FortiGate Network Virtual Appliance.        |
| `fortiGate2ResourceId` | `string` | The resource ID of the second FortiGate Network Virtual Appliance. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.