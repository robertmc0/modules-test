# Maintenance Configuration module

This module deploys Microsoft.Maintenance maintenanceConfigurations

## Details

{{Add detailed information about the module}}

## Parameters

| Name                              | Type     | Required | Description                                                                                |
| :-------------------------------- | :------: | :------: | :----------------------------------------------------------------------------------------- |
| `name`                            | `string` | Yes      | Maintenance Configuration Name.                                                            |
| `inGuestPatchMode`                | `string` | No       | Optional. Specifies the mode of in-guest patching to IaaS virtual machine.                 |
| `linuxClassificationsToInclude`   | `array`  | No       | Optional. Choose classification of patches to include in Linux patching.                   |
| `location`                        | `string` | Yes      | Location for all Resources.                                                                |
| `maintenanceScope`                | `string` | No       | Optional. Gets or sets maintenanceScope of the configuration.                              |
| `maintenanceWindow`               | `object` | No       | Optional. Definition of a MaintenanceWindow.                                               |
| `rebootSetting`                   | `string` | No       | Optional. Sets the reboot setting for the patches.                                         |
| `resourceLock`                    | `string` | No       | Optional. Specify the type of resource lock.                                               |
| `tags`                            | `object` | No       | Optional. Resource tags.                                                                   |
| `visibility`                      | `string` | No       | Optional. Gets or sets the visibility of the configuration. The default value is 'Custom'. |
| `windowsClassificationsToInclude` | `array`  | No       | Optional. Choose classification of patches to include in Windows patching.                 |
| `windowsKbNumbersToExclude`       | `array`  | No       | Optional. Choose patch KB to exclude from Windows patching.                                |
| `linuxPackageNameMasksToExclude`  | `array`  | No       | Optional. Choose packages to exclude from linux updates.                                   |

## Outputs

| Name         | Type     | Description                                       |
| :----------- | :------: | :------------------------------------------------ |
| `name`       | `string` | The name of the Maintenance Configuration.        |
| `resourceId` | `string` | The resource ID of the Maintenance Configuration. |

## Examples

### Example 1

Please see the [Bicep Tests](test/main.test.bicep) file for examples.