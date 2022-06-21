/*
Write deployment tests in this file. Any module that references the main
module file is a deployment test. Make sure at least one test is added.
*/

// ========== //
// Parameters //
// ========== //
@description('The location to deploy resources to')
param location string = 'australiaeast'

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints')
param companyShortName string = 'arn'

// ========== //
// Test Setup //
// ========== //
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${companyShortName}-tst-law-${uniqueString(deployment().name,'logAnalyticsWorkspace',location)}'
  location: location
}

resource diagnosticsStorageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${companyShortName}tstdiag${uniqueString(deployment().name,'diagnosticsStorageAccount',location)}'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${companyShortName}-tst-vnet-${uniqueString(deployment().name,'vnet',location)}'
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

// ============== //
// Test Execution //
// ============== //


module storageAccountMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-storage-account'
  params: {
    storageAccountName: uniqueString(deployment().name, 'storageAccountMinimum', location)
    location: location
    //allowBlobPublicAccess: false
  }
}

module storageAccount '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-storage-account'
  params: {
    storageAccountName: uniqueString(deployment().name, 'storageAccount', location)
    location: location
    //allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
    //requireInfrastructureEncryption: true    
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
    }
    // blobServices: {
    //   diagnosticLogsRetentionInDays: 7
    //   diagnosticWorkspaceId: logAnalyticsWorkspace.id
    //   containers: [
    //       {
    //           name: 'avdscripts'
    //           publicAccess: 'None'
    //       }
    //       {
    //           name: 'archivecontainer'
    //           publicAccess: 'None'
    //           enableWORM: true
    //           WORMRetention: 666
    //           allowProtectedAppendWrites: false
    //       }
    //   ]
    // }
    
    containers: [
        {
            containerName: 'avdscripts'
            publicAccess: 'None'
        }
        {
            containerName: 'archivecontainer'
            publicAccess: 'None'
            enableWORM: true
            WORMRetention: 666
            allowProtectedAppendWrites: false
        }
    ]

    // fileServices: {
    //   diagnosticLogsRetentionInDays: 7
    //   diagnosticStorageAccountId: diagnosticsStorageAccount.id
    //   diagnosticWorkspaceId: logAnalyticsWorkspace.id
    //   // diagnosticEventHubAuthorizationRuleId: "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey",
    //   // diagnosticEventHubName: "adp-<<namePrefix>>-az-evh-x-001",
    //   shares: [
    //       {
    //           name: 'avdprofiles'
    //           shareQuota: 5120
    //       }
    //       {
    //           name: 'avdprofiles2'
    //           shareQuota: 5120
    //       }
    //   ]
    // }
    fileShares: [
      {
        fileShareName: 'avdprofiles'
        fileShareQuota: 5120
      }
      {
        fileShareName: 'avdprofiles2'
        fileShareQuota: 5120
      }
    ]

    // tableServices: {
    //   diagnosticLogsRetentionInDays: 7
    //   diagnosticStorageAccountId: diagnosticsStorageAccount.id
    //   diagnosticWorkspaceId: logAnalyticsWorkspace.id
    //   // diagnosticEventHubAuthorizationRuleId: "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey",
    //   // diagnosticEventHubName: "adp-<<namePrefix>>-az-evh-x-001",
    //   tables: [
    //     'table1'
    //     'table2'
    //   ]
    // }

    tables: [
      {
        tableName: 'table1'
      }
      {
        tableName: 'table2'
      }
    ]

    // queueServices: {
    //   diagnosticLogsRetentionInDays: 7
    //   diagnosticStorageAccountId: diagnosticsStorageAccount.id
    //   diagnosticWorkspaceId: logAnalyticsWorkspace.id
    //   // diagnosticEventHubAuthorizationRuleId: "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey",
    //   // diagnosticEventHubName: "adp-<<namePrefix>>-az-evh-x-001",
    //   queues: [
    //       {
    //           name: 'queue1'
    //           metadata: {}
    //       }
    //       {
    //           name: 'queue2'
    //           metadata: {}
    //       }
    //   ]
    // }

    queues: [
      {
          queueName: 'queue1'
          metadata: {}
      }
      {
          queueName: 'queue2'
          metadata: {}
      }
    ]

    diagnosticLogsRetentionInDays: 7
    //diagnosticWorkspaceId: logAnalyticsWorkspace.id
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

module storageAccountNfs '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-nfs-storage-account'
  params: {
    storageAccountName: uniqueString(deployment().name, 'storageAccountNfs', location)
    location: location
    //allowBlobPublicAccess: false
    storageAccountSku: 'Premium_LRS'
    storageAccountKind: 'FileStorage'

    //supportsHttpsTrafficOnly: false
    // fileServices: {
    //   shares: [
    //     {
    //       name: 'nfsfileshare'
    //       enabledProtocols: 'NFS'
    //     }
    //   ]
    // }

    fileShares: [
      {
        fileShareName: 'nfsfileshare'
        fileShareProtocol: 'NFS'
      }
    ]

    //systemAssignedIdentity: true
    diagnosticLogsRetentionInDays: 7
    //diagnosticWorkspaceId: logAnalyticsWorkspace.id
    diagnosticLogAnalyticsWorkspaceId: logAnalyticsWorkspace.id
  }
}

module storageAccountDataLake '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-datalake-storage-account'
  params: {
    storageAccountName: uniqueString(deployment().name, 'storageAccountDataLake', location)
    location: location
    //supportsHttpsTrafficOnly: true
    enableHierarchicalNamespace: true // Required for Datalake
    //lock: 'ReadOnly'
    resourcelock: 'CanNotDelete'
  }
}
