/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${shortIdentifier}tstdiag${uniqueString(deployment().name, 'diagnosticsStorageAccount', location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet-${uniqueString(deployment().name, 'vnet', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
  resource subnet 'subnets@2021-05-01' = {
    name: 'app'
    properties: {
      addressPrefix: '10.0.0.0/27'
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
      ]
    }
  }
}

resource rsv 'Microsoft.RecoveryServices/vaults@2022-04-01' = {
  name: 'rsv'
  location: location
  properties: {}
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module storageAccountMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-storage-account'
  params: {
    name: '${uniqueString(deployment().name, location)}minsa'
    location: location
    publicNetworkAccess: 'Disabled'
  }
}

module storageAccount '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-storage-account'
  params: {
    name: '${uniqueString(deployment().name, location)}sa'
    location: location
    publicNetworkAccess: 'Enabled'
    requireInfrastructureEncryption: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: vnet::subnet.id
          action: 'Allow'
        }
      ]
      ipRules: [
        {
          action: 'Allow'
          value: '1.1.1.1'
        }
      ]
      resourceAccessRules: [
        {
          tenantId: subscription().tenantId
          resourceId: rsv.id
        }

      ]
    }

    containers: [
      {
        name: 'avdscripts'
        publicAccess: 'None'
      }
      {
        name: 'archivecontainer'
        publicAccess: 'None'
        enableWORM: true
        WORMRetention: 666
        allowProtectedAppendWrites: false
      }
    ]

    fileShares: [
      {
        name: 'avdprofiles'
        quota: 5120
      }
      {
        name: 'avdprofiles2'
        quota: 5120
      }
    ]

    tables: [
      {
        name: 'table1'
      }
      {
        name: 'table2'
      }
    ]

    queues: [
      {
        name: 'queue1'
        metadata: {}
      }
      {
        name: 'queue2'
        metadata: {}
      }
    ]

    enableDiagnostics: true
    diagnosticLogsRetentionInDays: 7
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

module storageAccountNfs '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-nfs-storage-account'
  params: {
    name: '${uniqueString(deployment().name, location)}nfssa'
    location: location
    publicNetworkAccess: 'Disabled'
    sku: 'Premium_LRS'
    kind: 'FileStorage'

    fileShares: [
      {
        name: 'nfsfileshare'
        protocol: 'NFS'
      }
    ]

    systemAssignedIdentity: true
    enableDiagnostics: true
    diagnosticLogsRetentionInDays: 7
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

module storageAccountDataLake '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-datalake-storage-account'
  params: {
    name: '${uniqueString(deployment().name, location)}dlakesa'
    location: location
    enableHierarchicalNamespace: true
    resourcelock: 'CanNotDelete'
  }
}
