# Virtual Machine Scale Sets Module

This module deploys Microsoft.Compute virtualMachineScaleSets

## Description

- Creates Microsoft.Compute virtualMachineScaleSets resource.
- Apply cloud-init configuration via customData.
- Applies capacity of scale set.
- Applies upgrade policy mode for scale set.
- Applies a lock to the scale set if the lock is specified.

## Parameters

| Name                       | Type           | Required | Description                                                                                                                                                                                                                                                  |
| :------------------------- | :------------: | :------: | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                     | `string`       | Yes      | The resource name.                                                                                                                                                                                                                                           |
| `location`                 | `string`       | Yes      | The geo-location where the resource lives.                                                                                                                                                                                                                   |
| `tags`                     | `object`       | No       | Optional. Resource tags.                                                                                                                                                                                                                                     |
| `size`                     | `string`       | Yes      | The VM size that you choose that determines factors such as processing power, memory, and storage capacity.                                                                                                                                                  |
| `osDiskType`               | `string`       | Yes      | Specifies the storage account type for the os managed disk.                                                                                                                                                                                                  |
| `networkInterfaceName`     | `string`       | Yes      | The network interface name.                                                                                                                                                                                                                                  |
| `computerNamePrefix`       | `string`       | Yes      | Specifies the computer name prefix for all of the virtual machines in the scale set. Computer name prefixes must be 1 to 15 characters long.                                                                                                                 |
| `adminUsername`            | `secureString` | Yes      | Specifies the name of the administrator account.                                                                                                                                                                                                             |
| `adminPassword`            | `secureString` | Yes      | Specifies the password of the administrator account. Refer to article for password requirements https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachinescalesets?pivots=deployment-language-bicep#virtualmachinescalesetosprofile. |
| `subnetResourceId`         | `string`       | Yes      | Resource ID of the virtual machine scale set subnet.                                                                                                                                                                                                         |
| `capacity`                 | `int`          | No       | Optional. Specifies the number of virtual machines in the scale set.                                                                                                                                                                                         |
| `imageReference`           | `object`       | Yes      | Specifies information about the image to use.                                                                                                                                                                                                                |
| `upgradePolicyMode`        | `string`       | No       | Optional. Specifies the mode of an upgrade to virtual machines in the scale set.                                                                                                                                                                             |
| `customData`               | `string`       | No       | Optional. Specifies a base-64 encoded string of custom data. The base-64 encoded string is decoded to a binary array that is saved as a file on the Virtual Machine. The maximum length of the binary array is 65535 bytes.                                  |
| `orchestrationMode`        | `string`       | No       | Optional. Specifies the orchestration mode for the virtual machine scale set.                                                                                                                                                                                |
| `scaleInPolicy`            | `object`       | No       | Optional. Specifies the policies applied when scaling in Virtual Machines in the Virtual Machine Scale Set.                                                                                                                                                  |
| `overprovision`            | `bool`         | No       | Optional. Specifies whether the Virtual Machine Scale Set should be overprovisioned.                                                                                                                                                                         |
| `platformFaultDomainCount` | `int`          | No       | Optional. Fault Domain count for each placement group.                                                                                                                                                                                                       |
| `availabilityZones`        | `array`        | No       | Optional. A list of availability zones denoting the zone in which the virtual machine scale set should be deployed.                                                                                                                                          |
| `resourceLock`             | `string`       | No       | Optional. Specify the type of resource lock.                                                                                                                                                                                                                 |

## Outputs

| Name       | Type   | Description                                                |
| :--------- | :----: | :--------------------------------------------------------- |
| name       | string | The name of the deployed virtual machine scale set.        |
| resourceId | string | The resource ID of the deployed virtual machine scale set. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.