/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
@description('Optional. The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@secure()
param vmPassword string = '${toUpper(uniqueString(resourceGroup().id))}-${newGuid()}'

@maxLength(15)
param vmNameMin string = substring(newGuid(), 0, 15)

@maxLength(15)
param vmName string = substring(newGuid(), 0, 13)

@maxLength(15)
param vmAzName string = substring(newGuid(), 0, 13)

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'default'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-12-01-preview' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: '${shortIdentifier}-tst-dcr-${uniqueString(deployment().name, 'dataCollectionRule', location)}'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dataSources: {
      performanceCounters: [
        {
          name: 'insightsMetricsCounterSpecifiers'
          streams: [
            'Microsoft-InsightsMetrics'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: [
            '\\VmInsights\\DetailedMetrics'
          ]
        }
        {
          name: 'perfCounterDataSource60'
          streams: [
            'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: 60
          counterSpecifiers: ['\\System\\Processes'] // Cannot be empty
        }
      ]
    }
    dataFlows: [
      {
        destinations: [
          'myloganalyticsworkspace'
        ]
        streams: [
          'Microsoft-Event'
          'Microsoft-InsightsMetrics'
          'Microsoft-Perf'
          'Microsoft-Syslog'
        ]
      }
    ]
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: string(logAnalyticsWorkspace.id)
          name: 'myloganalyticsworkspace'
        }
      ]
    }
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module vmMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vm-min'
  params: {
    name: vmNameMin
    location: location
    size: 'Standard_B1s'
    osStorageAccountType: 'StandardSSD_LRS'
    imageReference: {
      publisher: 'canonical'
      offer: '0001-com-ubuntu-server-focal'
      sku: '20_04-lts'
      version: 'latest'
    }
    adminUsername: 'azureuser'
    adminPassword: vmPassword
    subnetResourceId: '${vnet.id}/subnets/default'
    dataDisks: [
      {
        storageAccountType: 'StandardSSD_LRS'
        diskSizeGB: 1024
        caching: 'None'
        createOption: 'Empty'
      }
    ]
  }
}

module vm '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vm'
  params: {
    name: vmName
    location: location
    size: 'Standard_B1s'
    instanceCount: 2
    osStorageAccountType: 'StandardSSD_LRS'
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    windowsConfiguration: {
      enableAutomaticUpdates: true
      provisionVMAgent: true
      timeZone: 'AUS Eastern Standard Time'
    }
    adminUsername: 'azureuser'
    adminPassword: vmPassword
    subnetResourceId: '${vnet.id}/subnets/default'
    availabilitySetConfiguration: {
      name: '${vmName}-avail'
      platformFaultDomainCount: 2
      platformUpdateDomainCount: 5
    }
    dataDisks: [
      {
        storageAccountType: 'StandardSSD_LRS'
        diskSizeGB: 1024
        caching: 'None'
        createOption: 'Empty'
      }
    ]
    antiMalwareConfiguration: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: true
        scanType: 'Quick'
        day: '7'
        time: '120'
      }
    }
    enableSecurityProfile: true
    encryptionAtHost: true
    securityType: 'TrustedLaunch'
    secureBootEnabled: true
    vTpmEnabled: true
    dataCollectionRuleId: string(dcr.id)
  }
}

module vmAz '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vm-az'
  params: {
    name: vmAzName
    location: location
    size: 'Standard_B1s'
    instanceCount: 2
    osStorageAccountType: 'StandardSSD_LRS'
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2022-datacenter-azure-edition'
      version: 'latest'
    }
    windowsConfiguration: {
      enableAutomaticUpdates: true
      patchSettings: {
        assessmentMode: 'AutomaticByPlatform'
        patchMode: 'AutomaticByPlatform'
        automaticByPlatformSettings: {
          rebootSetting: 'IfRequired'
          bypassPlatformSafetyChecksOnUserSchedule: true
        }
      }
    }
    adminUsername: 'azureuser'
    adminPassword: vmPassword
    subnetResourceId: '${vnet.id}/subnets/default'
    autoAssignAvailabilityZones: true
    dataDisks: [
      {
        storageAccountType: 'StandardSSD_LRS'
        diskSizeGB: 1024
        caching: 'None'
        createOption: 'Empty'
      }
    ]
    antiMalwareConfiguration: {
      AntimalwareEnabled: true
      RealtimeProtectionEnabled: true
      ScheduledScanSettings: {
        isEnabled: true
        scanType: 'Quick'
        day: '7'
        time: '120'
      }
    }
    enableSecurityProfile: true
    encryptionAtHost: true
    securityType: 'TrustedLaunch'
    secureBootEnabled: true
    vTpmEnabled: true
    dataCollectionRuleId: string(dcr.id)
  }
}
