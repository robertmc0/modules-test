# SQL Server

This module deployes Microsoft.sql servers, threat protection, audit setting and lock

## Details

{{Add detailed information about the module}}

## Parameters

| Name                                           | Type           | Required | Description                                                                                                                                              |
| :--------------------------------------------- | :------------: | :------: | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                         | `string`       | Yes      | Name of the Azure SQL resource.                                                                                                                          |
| `location`                                     | `string`       | Yes      | Location of the resource.                                                                                                                                |
| `administratorLogin`                           | `string`       | No       | Optional. Administrator username for the server. Required if no `administrators` object for AAD authentication is provided.                              |
| `administratorLoginPassword`                   | `securestring` | No       | Optional. The administrator login password. Required if no `administrators` object for AAD authentication is provided.                                   |
| `administrators`                               | `object`       | No       | Optional. The Azure Active Directory (AAD) administrator authentication. Required if no `administratorLogin` & `administratorLoginPassword` is provided. |
| `publicNetworkAccess`                          | `string`       | No       | Optional. Enable/Disable Public Network Access. Only Disable if you wish to restrict to just private endpoints and VNET.                                 |
| `allowTrustedAzureServices`                    | `bool`         | No       | Optional. Enables trusted Azure services to access the sql server bypassing firewall restrictions  PublicNetworkAccess must be enabled for this.         |
| `connectionType`                               | `string`       | No       | Optional. The server connection type. - Default, Proxy, Redirect.  Note private link requires Proxy.                                                     |
| `tags`                                         | `object`       | No       | Optional. Resource tags.                                                                                                                                 |
| `vulnerabilityAssessmentStorageAccountName`    | `string`       | Yes      | Name of Storage Account to store Vulnerability Assessments.                                                                                              |
| `vulnerabilityAssessmentStorageResourceGroup`  | `string`       | No       | Optional. Resource Group of Storage Account to store Vulnerability Assessments.                                                                          |
| `vulnerabilityAssessmentStorageSubscriptionId` | `string`       | No       | Optional. Subscription Id of Storage Account to store Vulnerability Assessments.                                                                         |
| `emailAccountAdmins`                           | `bool`         | No       | Optional. Specifies that the alert is sent to the account/subscription administrators.                                                                   |
| `emailAddresses`                               | `array`        | No       | Optional. Array of e-mail addresses to which the alert and vulnerability scans are sent.                                                                 |
| `resourcelock`                                 | `string`       | No       | Optional. Specify the type of lock.                                                                                                                      |
| `subnetResourceId`                             | `string`       | No       | Optional. The full resource ID of a subnet in a virtual network to deploy the API Management service in.                                                 |
| `systemAssignedIdentity`                       | `bool`         | No       | Optional. Enables system assigned managed identity on the resource.                                                                                      |
| `threatDetectionRetentionDays`                 | `int`          | No       | Optional. Specifies the number of days to keep in the audit logs. Zero means keep forever.                                                               |
| `userAssignedIdentities`                       | `object`       | No       | Optional. The ID(s) to assign to the resource.                                                                                                           |
| `enableAudit`                                  | `bool`         | No       | Optional. Enable audit logging.                                                                                                                          |
| `auditLogAnalyticsWorkspaceId`                 | `string`       | No       | Optional. Resource ID of the audit log analytics workspace.                                                                                              |
| `auditEventHubAuthorizationRuleId`             | `string`       | No       | Optional. Resource ID of the audit event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to.    |
| `auditEventHubName`                            | `string`       | No       | Optional. Name of the audit event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category.      |
| `auditLogsRetentionInDays`                     | `int`          | No       | Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.                                           |
| `auditStorageAccountName`                      | `string`       | Yes      | Name of Storage Account to store audit logs.                                                                                                             |
| `auditStorageResourceGroup`                    | `string`       | No       | Optional. Resource Group of Storage Account to store audit logs.                                                                                         |
| `auditStorageSubscriptionId`                   | `string`       | No       | Optional. Subscription Id of Storage Account to store audit logs.                                                                                        |

## Outputs

| Name                        | Type     | Description                                                      |
| :-------------------------- | :------: | :--------------------------------------------------------------- |
| `name`                      | `string` | The name of the sql server.                                      |
| `resourceId`                | `string` | The resource ID of the sql server.                               |
| `resourceGroupName`         | `string` | The resource group the API management service was deployed into. |
| `systemAssignedPrincipalId` | `string` | The principal ID of the system assigned identity.                |

## Examples

See [Tests File](test/main.test.bicep)