# Maintenance Configurations Module

This module deploys Microsoft.Maintenance maintenanceConfigurations

## Description

This module performs the following:

- Creates Microsoft.Maintenance maintenanceConfigurations resource.
- Applies a lock if required.

## Parameters

| Name                              | Type     | Required | Description                                                                                |
| :-------------------------------- | :------: | :------: | :----------------------------------------------------------------------------------------- |
| `name`                            | `string` | Yes      | Required. Maintenance Configuration Name.                                                  |
| `linuxClassificationsToInclude`   | `array`  | No       | Optional. Choose classification of patches to include in Linux patching.                   |
| `location`                        | `string` | No       | Optional. Location for all Resources.                                                      |
| `lock`                            | `string` | No       | Optional. Specify the type of lock.                                                        |
| `maintenanceScope`                | `string` | No       | Optional. Gets or sets maintenanceScope of the configuration.                              |
| `maintenanceWindow`               | `object` | No       | Optional. Definition of a MaintenanceWindow.                                               |
| `rebootSetting`                   | `string` | No       | Optional. Sets the reboot setting for the patches.                                         |
| `tags`                            | `object` | No       | Optional. Gets or sets tags of the resource.                                               |
| `visibility`                      | `string` | No       | Optional. Gets or sets the visibility of the configuration. The default value is 'Custom'. |
| `windowsClassificationsToInclude` | `array`  | No       | Optional. Choose classification of patches to include in Windows patching.                 |

## Outputs

| Name       | Type   | Description                                       |
| :--------- | :----: | :------------------------------------------------ |
| name       | string | The name of the Maintenance Configuration.        |
| resourceId | string | The resource ID of the Maintenance Configuration. |

## Examples

### Example 1

Please see the [Bicep Tests](test/main.test.bicep) file for examples.
