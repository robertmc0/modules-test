# Sql Server Module

This module deploys Microsoft.Sql servers.

## Details

<<<<<<< HEAD
{{Add detailed information about the module}}

## Parameters

| Name                                    | Type           | Required | Description                                                                                                                                          |
| :-------------------------------------- | :------------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string`       | Yes      | The resource name.                                                                                                                                   |
| `location`                              | `string`       | Yes      | The geo-location where the resource lives.                                                                                                           |
| `tags`                                  | `object`       | No       | Optional. Resource tags.                                                                                                                             |
| `administratorLogin`                    | `string`       | No       | Optional. Administrator username for the server. Once created it cannot be changed. Required if "administrators" is not provided.                    |
| `administratorLoginPassword`            | `securestring` | No       | Optional. The administrator login password. Required if "administrators" is not provided.                                                            |
| `administrators`                        | `object`       | No       | Optional. The Azure Active Directory administrator of the server. Required if "administratorLogin" and "administratorLoginPassword" is not provided. |
| `publicNetworkAccess`                   | `string`       | No       | Optional. Whether or not public endpoint access is allowed for this server. Only Disable if you wish to restrict to just private endpoints and VNET. |
| `allowTrustedAzureServices`             | `bool`         | No       | Optional. Enables trusted Azure services to access the sql server bypassing firewall restrictions  PublicNetworkAccess must be enabled for this.     |
| `connectionType`                        | `string`       | No       | Optional. The server connection type. Note private link requires Proxy.                                                                              |
| `enableVulnerabilityAssessments`        | `bool`         | No       | Optional. Enable Vulnerability Assessments. Not currently supported with user managed identities.                                                    |
| `vulnerabilityAssessmentStorageId`      | `string`       | No       | Optional. Resource ID of the Storage Account to store Vulnerability Assessments. Required when enableVulnerabilityAssessments set to "true".         |
| `enableAudit`                           | `bool`         | No       | Optional. Enable Audit logging.                                                                                                                      |
| `auditStorageAccountId`                 | `string`       | No       | Optional. Resource ID of the Storage Account to store Audit logs. Required when enableAudit set to "true".                                           |
| `emailAccountAdmins`                    | `bool`         | No       | Optional. Specifies that the schedule scan notification will be is sent to the subscription administrators.                                          |
| `emailAddresses`                        | `array`        | No       | Optional. Specifies an array of e-mail addresses to which the scan notification is sent.                                                             |
| `subnetResourceId`                      | `string`       | No       | Optional. Resource ID of the virtual network subnet to configure as a virtual network rule.                                                          |
| `systemAssignedIdentity`                | `bool`         | No       | Optional. Enables system assigned managed identity on the resource.                                                                                  |
| `userAssignedIdentities`                | `object`       | No       | Optional. The ID(s) to assign to the resource.                                                                                                       |
| `primaryUserAssignedIdentityId`         | `string`       | No       | Optional. The resource ID of a user assigned identity to be used by default.                                                                         |
| `threatDetectionRetentionDays`          | `int`          | No       | Optional. Specifies the number of days to keep in the Threat Detection audit logs. Zero means keep forever.                                          |
| `enableDiagnostics`                     | `bool`         | No       | Optional. Enable diagnostic logging.                                                                                                                 |
| `diagnosticLogCategoriesToEnable`       | `array`        | No       | Optional. The name of log category groups that will be streamed.                                                                                     |
| `diagnosticMetricsToEnable`             | `array`        | No       | Optional. The name of metrics that will be streamed.                                                                                                 |
| `diagnosticStorageAccountId`            | `string`       | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                                            |
| `diagnosticLogAnalyticsWorkspaceId`     | `string`       | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                                    |
| `diagnosticEventHubAuthorizationRuleId` | `string`       | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.                              |
| `diagnosticEventHubName`                | `string`       | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                                         |
| `resourceLock`                          | `string`       | No       | Optional. Specify the type of resource lock.                                                                                                         |

## Outputs

| Name                        | Type     | Description                                          |
| :-------------------------- | :------: | :--------------------------------------------------- |
| `name`                      | `string` | The name of the sql server.                          |
| `resourceId`                | `string` | The resource ID of the sql server.                   |
| `resourceGroupName`         | `string` | The resource group the sql server was deployed into. |
| `systemAssignedPrincipalId` | `string` | The principal ID of the system assigned identity.    |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.