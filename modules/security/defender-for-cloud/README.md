# Defender for Cloud Module

This module deploys Microsoft Defender for Cloud plans, contacts and configuration settings.

## Description

This module performs the following

- Configures security contact for Defender for Cloud alerts.
- Configures Defender for Cloud plans.
- Configures auto provisioning of new resources if specified.

## Parameters

| Name                                       | Type     | Required | Description                                                                                                                          |
| :----------------------------------------- | :------: | :------: | :----------------------------------------------------------------------------------------------------------------------------------- |
| `emailAddress`                             | `string` | Yes      | Email address which will get notifications from Microsoft Defender for Cloud by the configurations defined in this security contact. |
| `phone`                                    | `string` | No       | Optional. The security contact's phone number.                                                                                       |
| `alertNotificationSeverity`                | `string` | Yes      | Defines the minimal alert severity which will be sent as email notifications.                                                        |
| `notificationsByRole`                      | `array`  | No       | Optional. Defines which RBAC roles will get email notifications from Microsoft Defender for Cloud.                                   |
| `pricingCloudPosture`                      | `string` | No       | Optional. The default pricing tier for Cloud Security Posture Management (CSPM) plan.                                                |
| `pricingTierVMs`                           | `string` | No       | Optional. The pricing tier for Microsoft Defender for Servers.                                                                       |
| `pricingTierSqlServers`                    | `string` | No       | Optional. The pricing tier for Microsoft Defender for SQL.                                                                           |
| `pricingTierAppServices`                   | `string` | No       | Optional. The pricing tier for Microsoft Defender for App Service.                                                                   |
| `pricingTierStorageAccounts`               | `string` | No       | Optional. The pricing tier for Microsoft Defender for Storage.                                                                       |
| `pricingTierSqlServerVirtualMachines`      | `string` | No       | Optional. The pricing tier for Microsoft Defender for SQL VMs.                                                                       |
| `pricingTierOpenSourceRelationalDatabases` | `string` | No       | Optional. The pricing tier for Microsoft Defender for Open Source Relational Databases.                                              |
| `pricingTierKubernetesService`             | `string` | No       | Optional. The pricing tier for Microsoft Defender for Kubernetes.                                                                    |
| `pricingTierContainerRegistry`             | `string` | No       | Optional. The pricing tier for Microsoft Defender for Azure Container Registry.                                                      |
| `pricingTierContainers`                    | `string` | No       | Optional. The pricing tier for Microsoft Defender for Containers.                                                                    |
| `pricingTierKeyVaults`                     | `string` | No       | Optional. The pricing tier for Microsoft Defender for Key Vaults.                                                                    |
| `pricingTierDns`                           | `string` | No       | Optional. The pricing tier for Microsoft Defender for DNS.                                                                           |
| `pricingTierArm`                           | `string` | No       | Optional. The pricing tier for Microsoft Defender for ARM.                                                                           |
| `pricingTierCosmosDbs`                     | `string` | No       | Optional. The pricing tier for Microsoft Defender for CosmosDbs.                                                                     |
| `workspaceId`                              | `string` | Yes      | Resource ID of the Log Analytics workspace.                                                                                          |
| `autoProvision`                            | `string` | No       | Optional. Automatically enable new resources into the log analytics workspace.                                                       |

## Outputs

| Name | Type | Description |
| :--- | :--: | :---------- |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.