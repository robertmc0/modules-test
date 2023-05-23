// Required due to Bicep requirement
// A resource's scope must match the scope of the Bicep file for it to be deployable. You must use modules to deploy resources to a different scope.

@description('Storage account name.')
param storageAccountName string

@description('Principal ID of the identity to grant storage account permissions to.')
param principalId string

var storageBlobContributorRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')

var storageBlobContributorRoleDefinitionId = guid(storageAccountName, storageBlobContributorRoleId, principalId)

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' existing = {
  name: storageAccountName
}

resource roleDefinition 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  scope: storageAccount
  name: storageBlobContributorRoleDefinitionId
  properties: {
    principalId: principalId
    roleDefinitionId: storageBlobContributorRoleId
    principalType: 'ServicePrincipal'
  }
}
