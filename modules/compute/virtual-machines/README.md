# Virtual Machines Module

This module deploys Microsoft.Compute virtualMachines

## Description

This module performs the following

- Creates Microsoft.Compute virtualMachines resource.
- Creates multiple instances.
- Adds virtual machine to availability set if specified.
- Applies Azure Monitor extension if specified.
- Applies Microsoft Antimalware extension if specified.
- Applies AD Domain Join extension if specified.
- Applies DSC extension if specified.
- Adds data disks if specified.
- Adds custom data if specified.
- Adds Security Profiles if specified
- Applies a lock to the virtual machine if the lock is specified.

## Parameters

| Name                                | Type           | Required | Description                                                                                                                                                                                                                       |
| :---------------------------------- | :------------: | :------: | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                              | `string`       | Yes      | The resource name.                                                                                                                                                                                                                |
| `location`                          | `string`       | Yes      | The geo-location where the resource lives.                                                                                                                                                                                        |
| `tags`                              | `object`       | No       | Optional. Resource tags.                                                                                                                                                                                                          |
| `instanceCount`                     | `int`          | No       | Optional. Number of virtual machine instances to deploy. Digit ## (e.g. 07) will be appended to the resource name if more than one instance is deployed.                                                                          |
| `imageReference`                    | `object`       | Yes      | Specifies information about the image to use.                                                                                                                                                                                     |
| `availabilityZones`                 | `array`        | No       | Optional. A list of availability zones denoting the zone in which the virtual machine should be deployed.                                                                                                                         |
| `availabilitySetConfiguration`      | `object`       | No       | Optional. The availability set configuration for the virtual machine. Not required if availabilityZones is set.                                                                                                                   |
| `size`                              | `string`       | Yes      | Specifies the size of the virtual machine.                                                                                                                                                                                        |
| `adminUsername`                     | `string`       | Yes      | Specifies the name of the administrator account.                                                                                                                                                                                  |
| `adminPassword`                     | `securestring` | Yes      | Specifies the password of the administrator account. Refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#osprofile for password complexity requirements. |
| `customData`                        | `string`       | No       | Optional. Specifies a base-64 encoded string of custom data.                                                                                                                                                                      |
| `linuxConfiguration`                | `object`       | No       | Optional. Specifies the Linux operating system settings on the virtual machine.                                                                                                                                                   |
| `windowsConfiguration`              | `object`       | No       | Specifies Windows operating system settings on the virtual machine.                                                                                                                                                               |
| `systemAssignedIdentity`            | `bool`         | No       | Optional. Enables system assigned managed identity on the resource.                                                                                                                                                               |
| `userAssignedIdentities`            | `object`       | No       | Optional. The ID(s) to assign to the resource.                                                                                                                                                                                    |
| `osStorageAccountType`              | `string`       | Yes      | Specifies the storage account type for the os managed disk.                                                                                                                                                                       |
| `dataDisks`                         | `array`        | No       | Optional. Specifies the parameters that are used to add a data disk to a virtual machine.                                                                                                                                         |
| `subnetResourceId`                  | `string`       | Yes      | Resource ID of the virtual machine subnet.                                                                                                                                                                                        |
| `licenseType`                       | `string`       | No       | Optional. Specifies that the image or disk that is being used was licensed on-premises. Accepted values "Windows_Client", "Windows_Server", "RHEL_BYOS" or "SLES_BYOS".                                                           |
| `diagnosticLogAnalyticsWorkspaceId` | `string`       | No       | Optional. Log analytics workspace resource id. Only required to enable VM Diagnostics.                                                                                                                                            |
| `antiMalwareConfiguration`          | `object`       | No       | Optional. Microsoft antimalware configuration. Will not be installed if left blank.                                                                                                                                               |
| `domainJoinSettings`                | `object`       | No       | Optional. Domain join configuration. Will not be domain joined if left blank.                                                                                                                                                     |
| `domainJoinPassword`                | `securestring` | No       | Optional. Password for the domain join user account.                                                                                                                                                                              |
| `dscConfiguration`                  | `object`       | No       | Optional. Desired state configuration. Will not be executed if left blank.                                                                                                                                                        |
| `resourceLock`                      | `string`       | No       | Optional. Specify the type of resource lock.                                                                                                                                                                                      |
| `enableSecurityProfile`             | `bool`         | No       | Optional. Enables the Security related profile settings for the virtual machine. Only supported on Gen 2 VMs.                                                                                                                     |
| `encryptionAtHost`                  | `bool`         | No       | Optional. Enable the encryption for all the disks including Resource/Temp disk at host itself.                                                                                                                                    |
| `securityType`                      | `string`       | No       | Optional. Specifies the SecurityType of the virtual machine. It has to be set to any specified value to enable UefiSettings.                                                                                                      |
| `secureBootEnabled`                 | `bool`         | No       | Optional. Enable secure boot on the virtual machine.                                                                                                                                                                              |
| `vTpmEnabled`                       | `bool`         | No       | Optional. Enable vTPM on the virtual machine.                                                                                                                                                                                     |

## Outputs

| Name       | Type  | Description                                       |
| :--------- | :---: | :------------------------------------------------ |
| name       | array | The name of the deployed virtual machines.        |
| resourceId | array | The resource ID of the deployed virtual machines. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.