# Autoscale settings module

This module deploys a Microsoft.Insights/autoscalesettings resource.

## Details

- Creates `Microsoft.Insights/autoscalesettings` resource.

## Parameters

| Name               | Type     | Required | Description                                                                                                        |
| :----------------- | :------: | :------: | :----------------------------------------------------------------------------------------------------------------- |
| `location`         | `string` | Yes      | The geo-location where the resource lives.                                                                         |
| `targetResourceId` | `string` | Yes      | The resource identifier of the resource that the autoscale setting should be added to.                             |
| `customEmails`     | `array`  | Yes      | The custom e-mails list. This value can be null or empty, in which case this attribute will be ignored.            |
| `profiles`         | `array`  | Yes      | The collection of automatic scaling profiles that specify different scaling parameters for different time periods. |

## Outputs

| Name         | Type     | Description                                |
| :----------- | :------: | :----------------------------------------- |
| `resourceId` | `string` | The ID of the Autoscale Settings resource. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.