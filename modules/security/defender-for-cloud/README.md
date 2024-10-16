# Defender for Cloud Module

This module deploys Microsoft Defender for Cloud plans, contacts and configuration settings.

## Details

{{Add detailed information about the module}}

## Parameters

| Name                        | Type     | Required | Description                                                                                                                                           |
| :-------------------------- | :------: | :------: | :---------------------------------------------------------------------------------------------------------------------------------------------------- |
| `emailAddress`              | `string` | Yes      | Email address which will get notifications from Microsoft Defender for Cloud by the configurations defined in this security contact.                  |
| `phone`                     | `string` | No       | Optional. The security contact's phone number.                                                                                                        |
| `alertNotificationSeverity` | `string` | Yes      | Defines the minimal alert severity which will be sent as email notifications.                                                                         |
| `notificationsByRole`       | `array`  | No       | Optional. Defines which RBAC roles will get email notifications from Microsoft Defender for Cloud.                                                    |
| `defenderPlans`             | `array`  | No       | Optional. The plans Microsoft Defender for Cloud.                                                                                                     |
| `workspaceId`               | `string` | Yes      | Resource ID of the Log Analytics workspace.                                                                                                           |
| `workspaceScope`            | `string` | No       | Optional. All the VMs in this scope will send their security data to the mentioned workspace unless overridden by a setting with more specific scope. |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.