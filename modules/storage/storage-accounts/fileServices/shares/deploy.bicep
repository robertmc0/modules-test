@maxLength(24)
@description('Required. Name of the Storage Account.')
param storageAccountName string

@description('Optional. The name of the file service')
param fileServicesName string = 'default'

@description('Required. The name of the file share to create')
param name string

@description('Optional. The maximum size of the share, in gigabytes. Must be greater than 0, and less than or equal to 5TB (5120). For Large File Shares, the maximum size is 102400.')
param sharedQuota int = 5120

@allowed([
  'NFS'
  'SMB'
])
@description('Optional. The authentication protocol that is used for the file share. Can only be specified when creating a share.')
param enabledProtocols string = 'SMB'

@allowed([
  'AllSquash'
  'NoRootSquash'
  'RootSquash'
])
@description('Optional. Permissions for NFS file shares are enforced by the client OS rather than the Azure Files service. Toggling the root squash behavior reduces the rights of the root user for NFS shares.')
param rootSquash string = 'NoRootSquash'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountName

  resource fileService 'fileServices@2021-04-01' existing = {
    name: fileServicesName
  }
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2021-08-01' = {
  name: name
  parent: storageAccount::fileService
  properties: {
    shareQuota: sharedQuota
    rootSquash: enabledProtocols == 'NFS' ? rootSquash : null
    enabledProtocols: enabledProtocols
  }
}

@description('The name of the deployed file share')
output name string = fileShare.name

@description('The resource ID of the deployed file share')
output resourceId string = fileShare.id

@description('The resource group of the deployed file share')
output resourceGroupName string = resourceGroup().name
