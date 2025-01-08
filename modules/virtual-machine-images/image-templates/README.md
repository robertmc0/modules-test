# Image Templates

This module deploys Microsoft.Compute/galleries/images AKA Image Templates

## Details

This module completes the following tasks:

- Creates a Microsoft.Compute/galleries/images resource.
- Creates a Microsoft.VirtualMachineImages/imageTemplates resource.
- Provides options to deploy Windows or Linux.
- Applies a lock to the component if specified.

## Parameters

| Name                         | Type     | Required | Description                                                                                      |
| :--------------------------- | :------: | :------: | :----------------------------------------------------------------------------------------------- |
| `location`                   | `string` | Yes      | Optional. The geo-location where the resource lives.                                             |
| `tags`                       | `object` | No       | Optional. Resource tags.                                                                         |
| `imageGalleryName`           | `string` | Yes      | Azure Image Gallery name.                                                                        |
| `imageDefinitionProperties`  | `object` | Yes      | Image definition to set for the custom image produced by the Azure Image Builder build.          |
| `imageTemplateName`          | `string` | Yes      | Image template name.                                                                             |
| `userIdentityId`             | `string` | Yes      | Resource ID of the user-assigned managed identity used by Azure Image Builder template.          |
| `vmSize`                     | `string` | No       | Optional. Size of virtual machine to use for image template.                                     |
| `subnetResourceId`           | `string` | Yes      | Resource ID of the virtual machine subnet.                                                       |
| `sourceImage`                | `object` | Yes      | Image definition of source image to use for image template.                                      |
| `hyperVGeneration`           | `string` | Yes      | The hypervisor generation of the Virtual Machine. Applicable to OS disks only.                   |
| `stagingResourceGroupId`     | `string` | No       | Optional. Resource ID of the staging resource group that host resources used during image build. |
| `runOutputName`              | `string` | Yes      | Image name to create and distribute using Azure Image Builder.                                   |
| `replicationRegions`         | `array`  | No       | Optional. Azure regions where you would like to replicate the custom image after it is created.  |
| `customizerScriptUri`        | `string` | Yes      | Storage Blob URL to the PowerShell script containing the image customisation configuration.      |
| `windowsUpdateConfiguration` | `array`  | No       | Optional. Windows update configuration for image template.                                       |
| `imageRecommendedSettings`   | `object` | No       | Optional. Recommended compute and memory settings for image.                                     |
| `osDiskSizeGB`               | `int`    | No       | Optional. OS disk size in gigabytes.                                                             |
| `buildTimeoutInMinutes`      | `int`    | No       | Optional. Build timeout in minutes.                                                              |
| `resourcelock`               | `string` | No       | Optional. Specify the type of resource lock.                                                     |

## Outputs

| Name         | Type     | Description                                     |
| :----------- | :------: | :---------------------------------------------- |
| `name`       | `string` | The name of the deployed image template.        |
| `resourceId` | `string` | The resource ID of the deployed image template. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.