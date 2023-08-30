# Data Factory Module

This module deploys Microsoft.DataFactory factories

## Description

This module performs the following

- Creates Microsoft.DataFactory factories resource.
- Configures Git with Azure DevOps or GitHub if specified.
- Configures managed virtual network if specified.
- Configures integration runtime within managed virtual network if specified.
- Configures data factory resource with system/user managed identities if specified.
- Applies diagnostic settings.
- Applies a lock to the data factory if the lock is specified.

## Parameters

| Name                                    | Type     | Required | Description                                                                                                                        |
| :-------------------------------------- | :------: | :------: | :--------------------------------------------------------------------------------------------------------------------------------- |
| `name`                                  | `string` | Yes      | The resource name.                                                                                                                 |
| `location`                              | `string` | Yes      | The geo-location where the resource lives.                                                                                         |
| `tags`                                  | `object` | No       | Optional. Resource tags.                                                                                                           |
| `enableManagedVirtualNetwork`           | `bool`   | No       | Optional. Enable managed virtual network.                                                                                          |
| `enableManagedVnetIntegrationRuntime`   | `bool`   | No       | Optional. Enable the integration runtime inside the managed virtual network. Only required if enableManagedVirtualNetwork is true. |
| `publicNetworkAccess`                   | `bool`   | No       | Optional. Enable or disable public network access.                                                                                 |
| `configureGit`                          | `bool`   | No       | Optional. Configure git during deployment.                                                                                         |
| `gitRepoType`                           | `string` | No       | Optional. Git repository type. Azure DevOps = FactoryVSTSConfiguration and GitHub = FactoryGitHubConfiguration.                    |
| `gitAccountName`                        | `string` | No       | Optional. Git account name. Azure DevOps = Organisation name and GitHub = Username.                                                |
| `gitProjectName`                        | `string` | No       | Optional. Git project name. Only relevant for Azure DevOps.                                                                        |
| `gitRepositoryName`                     | `string` | No       | Optional. Git repository name.                                                                                                     |
| `gitCollaborationBranch`                | `string` | No       | Optional. The collaboration branch name. Default is main.                                                                          |
| `gitRootFolder`                         | `string` | No       | Optional. The root folder path name. Default is /.                                                                                 |
| `systemAssignedIdentity`                | `bool`   | No       | Optional. Enables system assigned managed identity on the resource.                                                                |
| `userAssignedIdentities`                | `object` | No       | Optional. The ID(s) to assign to the resource.                                                                                     |
| `enableDiagnostics`                     | `bool`   | No       | Optional. Enable diagnostic logging.                                                                                               |
| `diagnosticLogCategoryGroupsToEnable`   | `array`  | No       | Optional. The name of log category groups that will be streamed.                                                                   |
| `diagnosticMetricsToEnable`             | `array`  | No       | Optional. The name of metrics that will be streamed.                                                                               |
| `diagnosticStorageAccountId`            | `string` | No       | Optional. Storage account resource id. Only required if enableDiagnostics is set to true.                                          |
| `diagnosticLogAnalyticsWorkspaceId`     | `string` | No       | Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.                                  |
| `diagnosticEventHubAuthorizationRuleId` | `string` | No       | Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.            |
| `diagnosticEventHubName`                | `string` | No       | Optional. Event hub name. Only required if enableDiagnostics is set to true.                                                       |
| `resourceLock`                          | `string` | No       | Optional. Specify the type of resource lock.                                                                                       |

## Outputs

| Name                      | Type   | Description                                       |
| :------------------------ | :----: | :------------------------------------------------ |
| name                      | string | The name of the deployed data factory.            |
| resourceId                | string | The resource ID of the deployed data factory.     |
| systemAssignedPrincipalId | string | The principal ID of the system assigned identity. |

## Examples

### Example 1 - Data Factory with Azure DevOps Git configuration

```bicep
param deploymentName string = 'adf${utcNow()}'
param location string = resourceGroup().location

module dataFactory 'datafactory.bicep' = {
  name: deploymentName
  params: {
    name: 'myDataFactoryName'
    location: location
    configureGit: true
    gitRepoType: 'FactoryVSTSConfiguration'
    gitAccountName: 'MyDevOpsOrgName'
    gitProjectName: 'MyDevOpsProjectName'
    gitRepositoryName: 'MyDevOpsRepoName'
  }
}
```

### Example 2 - Data Factory with GitHub Git configuration

```bicep
param deploymentName string = 'adf${utcNow()}'
param location string = resourceGroup().location

module dataFactory 'datafactory.bicep' = {
  name: deploymentName
  params: {
    name: 'myDataFactoryName'
    location: location
    configureGit: true
    gitRepoType: 'FactoryGitHubConfiguration'
    gitAccountName: 'MyGitHubUsername'
    gitRepositoryName: 'MyGitHubReponame'
  }
}
```

Please see the [Bicep Tests](test/main.test.bicep) file for more examples.