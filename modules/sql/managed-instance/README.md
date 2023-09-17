# SQL Managed Instance

This module deploys Microsoft.Sql Managed Instance

## Details

This module performs the following

- Creates Microsoft.Sql managed instance resource.
- Associates given Azure AD account or group as SQL admin.
- Creates a system managed identity if specified.
- Associates existing user managed identities with SQL server and sets primary identity if specified.
- Creates databases on the managed instance if specified.
- Applies diagnostic settings on managed instance if specified.
- Applies a lock to the managed instance if the lock is specified.

## Parameters

| Name                                    | Type           | Required | Description                                                                                                                                          |
| :-------------------------------------- | :------------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string`       | Yes      | The name of the Managed Instance.                                                                                                                    |
| `location`                              | `string`       | Yes      | The geo-location where the resource lives.                                                                                                           |
| `tags`                                  | `object`       | No       | Optional. Resource tags.                                                                                                                             |
| `administratorLogin`                    | `string`       | No       | Optional. Administrator username for the server. Once created it cannot be changed. Required if "administrators" is not provided.                    |
| `administratorLoginPassword`            | `securestring` | No       | Optional. The administrator login password. Required if "administrators" is not provided.                                                            |
| `administrators`                        | `object`       | No       | Optional. The Azure Active Directory administrator of the server. Required if "administratorLogin" and "administratorLoginPassword" is not provided. |
| `skuName`                               | `string`       | Yes      | Specifies the sku of the managed instance.                                                                                                           |
| `vCores`                                | `int`          | Yes      | Specifies the number of vCores provisioned.                                                                                                          |
| `licenseType`                           | `string`       | No       | Optional. For Azure Hybrid Benefit, use BasePrice.                                                                                                   |
| `requestedBackupStorageRedundancy`      | `string`       | No       | Optional. Set location of backups, geo, local or zone.                                                                                               |
| `managedInstanceCreateMode`             | `string`       | No       | Optional. Specifies the mode of database creation.                                                                                                   |
| `restorePointInTime`                    | `string`       | No       | Optional. Specifies the point in time (ISO8601 format) of the source database that will be restored to create the new database.                      |
| `sourceManagedInstanceId`               | `string`       | No       | Optional. The resource identifier of the source managed instance associated with create operation of this instance.                                  |
| `collation`                             | `string`       | No       | Optional. The Managed Instance Collation.                                                                                                            |
| `publicDataEndpointEnabled`             | `bool`         | No       | Optional. Whether or not the public data endpoint is enabled.                                                                                        |
| `storageSizeInGB`                       | `int`          | Yes      | Optional. Storage size in GB. Minimum value: 32. Increments of 32 GB allowed only.                                                                   |
| `subnetResourceId`                      | `string`       | Yes      | Optional. Subnet resource ID for the managed instance.                                                                                               |
| `zoneRedundant`                         | `bool`         | No       | Optional. Whether or not the multi-az is enabled.                                                                                                    |
| `proxyOverride`                         | `string`       | No       | Optional. The server connection type. Note private link requires Proxy.                                                                              |
| `dnsZonePartner`                        | `string`       | No       | Optional. The resource id of another managed instance whose DNS zone this managed instance will share after creation.                                |
| `instancePoolId`                        | `string`       | No       | Optional. The Id of the instance pool this managed server belongs to.                                                                                |
| `timezoneId`                            | `string`       | No       | Optional. The Id of the TimeZone. (eg: "AUS Eastern Standard Time")                                                                                  |
| `enableVulnerabilityAssessments`        | `bool`         | No       | Optional. Enable Vulnerability Assessments. Not currently supported with user managed identities.                                                    |
| `vulnerabilityAssessmentStorageId`      | `string`       | No       | Optional. Resource ID of the Storage Account to store Vulnerability Assessments. Required when enableVulnerabilityAssessments set to "true".         |
| `emailAccountAdmins`                    | `bool`         | No       | Optional. Specifies that the schedule scan notification will be is sent to the subscription administrators.                                          |
| `emailAddresses`                        | `array`        | No       | Optional. Specifies an array of e-mail addresses to which the scan notification is sent.                                                             |
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

| Name         | Type     | Description                              |
| :----------- | :------: | :--------------------------------------- |
| `name`       | `string` | The name of the managed instance.        |
| `resourceId` | `string` | The resource ID of the managed instance. |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.