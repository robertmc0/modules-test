@description('The resource name.')
@maxLength(15)
param name string

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Optional. Number of virtual machine instances to deploy. Digit ## (e.g. 07) will be appended to the resource name if more than one instance is deployed.')
@minValue(1)
param instanceCount int = 1

@description('Specifies information about the image to use.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#imagereference'
  example: {
    publisher: 'string'
    offer: 'string'
    sku: 'string'
    version: 'string'
  }
})
param imageReference object

@description('Optional. A list of availability zones denoting the zone in which the virtual machine should be deployed.')
@allowed([
  '1'
  '2'
  '3'
])
param availabilityZones array = []

@description('Optional. The availability set configuration for the virtual machine. Not required if availabilityZones is set.')
@metadata({
  name: 'Availability set name.'
  platformFaultDomainCount: 'Fault Domain count.'
  platformUpdateDomainCount: 'Update Domain count.'
})
param availabilitySetConfiguration object = {}

@description('Specifies the size of the virtual machine. Refer to https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#hardwareprofile for values.')
param size string

@description('Specifies the name of the administrator account.')
param adminUsername string

@description('Specifies the password of the administrator account. Refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#osprofile for password complexity requirements.')
@secure()
param adminPassword string

@description('Optional. Specifies a base-64 encoded string of custom data.')
param customData string = ''

@description('Optional. Specifies the Linux operating system settings on the virtual machine.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#linuxconfiguration'
  example: {
    disablePasswordAuthentication: 'bool'
    patchSettings: {
      assessmentMode: 'string'
      automaticByPlatformSettings: {
        rebootSetting: 'string'
      }
      patchMode: 'string'
    }
    provisionVMAgent: 'bool'
    ssh: {
      publicKeys: {
        keyData: 'string'
        path: 'string'
      }
    }
  }
})
param linuxConfiguration object = {}

@description('Specifies Windows operating system settings on the virtual machine.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#windowsconfiguration'
  example: {
    additionalUnattendContent: {
      componentName: 'string'
      content: 'string'
      passName: 'OobeSystem'
      settingName: 'string'
    }
    enableAutomaticUpdates: 'bool'
    patchSettings: {
      assessmentMode: 'string'
      automaticByPlatformSettings: {
        rebootSetting: 'string'
      }
      enableHotpatching: 'bool'
      patchMode: 'string'
    }
    provisionVMAgent: 'bool'
    timeZone: 'string'
    winRM: {
      listeners: [
        {
          certificateUrl: 'string'
          protocol: 'string'
        }
      ]
    }
  }
})
param windowsConfiguration object = {}

@description('Optional. Enables system assigned managed identity on the resource.')
param systemAssignedIdentity bool = false

@description('Optional. The ID(s) to assign to the resource.')
param userAssignedIdentities object = {}

@description('Specifies the storage account type for the os managed disk.')
@allowed([
  'PremiumV2_LRS'
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param osStorageAccountType string

@description('Optional. Specifies the parameters that are used to add a data disk to a virtual machine.')
@metadata({
  storageAccountType: 'Specifies the storage account type for the managed disk.'
  diskSizeGB: 'Specifies the size of an empty data disk in gigabytes.'
  caching: 'Specifies the caching requirements. Accepted values are "None", "ReadOnly" or "ReadWrite".'
})
param dataDisks array = []

@description('Resource ID of the virtual machine subnet.')
param subnetResourceId string

@description('Optional. Specifies that the image or disk that is being used was licensed on-premises. Accepted values "Windows_Client", "Windows_Server", "RHEL_BYOS" or "SLES_BYOS".')
param licenseType string = ''

@description('Optional. Log analytics workspace resource id. Only required to enable VM Diagnostics.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Microsoft antimalware configuration. Will not be installed if left blank.')
@metadata({
  AntimalwareEnabled: 'Enables the Antimalware service. Accepted values "true or "false".'
  Exclusions: {
    Extensions: 'List of file extensions to exclude from scanning.'
    Paths: 'List of path to files or folders to exclude.'
    Processes: 'List of process exclusions.'
  }
  RealtimeProtectionEnabled: 'Enable real-time protection.'
  ScheduledScanSettings: {
    isEnabled: 'Enables or disables a periodic scan. Accepted values "true or "false".'
    scanType: 'Scan scheduled type.'
    day: '0 - scan daily, 1 - Sunday, 2 - Monday, 3 - Tuesday..., 7 - Saturday, 8 - disabled.'
    time: 'Hour at which to begin the scheduled scan. Measured in 60 minute increments. 60 mins = 1am, 120 mins = 2am.'
  }
})
param antiMalwareConfiguration object = {}

@description('Optional. Domain join configuration. Will not be domain joined if left blank.')
@metadata({
  domainToJoin: 'FQDN of the domain to which the session host virtual machines will be joined. E.g. contoso.com.'
  ouPath: 'Organisational unit (OU) to place the session host virtual machines when joining the domain. E.g. OU=testOU;DC=domain;DC=Domain;DC=com.'
  domainJoinUser: 'Username that has privileges to join the session host virtual machines to the domain.'
  domainJoinPassword: 'Password for the domain join user account.'
})
param domainJoinSettings object = {}

@description('Optional. Password for the domain join user account.')
@secure()
param domainJoinPassword string = ''

@description('Optional. Desired state configuration. Will not be executed if left blank.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/dsc-windows'
  example: {
    configuration: {
      url: 'http://validURLToConfigLocation'
      script: 'ConfigurationScript.ps1'
      function: 'ConfigurationFunction'
    }
    configurationArguments: {
      argument1: 'Value1'
      argument2: 'Value2'
    }
  }
})
param dscConfiguration object = {}

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockSuffix = '-lck'

var networkInterfaceSuffix = '-nic'

var osDiskSuffix = '-osdisk'

var dataDiskSuffix = '-disk-'

var identityType = systemAssignedIdentity ? (!empty(userAssignedIdentities) ? 'SystemAssigned,UserAssigned' : 'SystemAssigned') : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-07-01' = [for i in range(0, instanceCount): {
  name: '${name}${format('{0:D2}', i + 1)}${networkInterfaceSuffix}'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetResourceId
          }
          privateIPAllocationMethod: 'Dynamic'
        }
      }
    ]
  }
}]

resource availabilitySet 'Microsoft.Compute/availabilitySets@2022-08-01' = if (!empty(availabilitySetConfiguration)) {
  name: !empty(availabilitySetConfiguration) ? availabilitySetConfiguration.name : 'placeholder'
  location: location
  tags: tags
  sku: {
    name: 'Aligned'
  }
  properties: {
    platformFaultDomainCount: availabilitySetConfiguration.platformFaultDomainCount
    platformUpdateDomainCount: availabilitySetConfiguration.platformUpdateDomainCount
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-08-01' = [for i in range(0, instanceCount): {
  dependsOn: [
    networkInterface
  ]
  name: '${name}${format('{0:D2}', i + 1)}'
  location: location
  tags: tags
  identity: identity
  zones: availabilityZones
  properties: {
    availabilitySet: !empty(availabilitySetConfiguration) ? {
      id: availabilitySet.id
    } : null
    networkProfile: {
      networkInterfaces: [
        {
          id: az.resourceId('Microsoft.Network/networkInterfaces', '${name}${format('{0:D2}', i + 1)}${networkInterfaceSuffix}')
        }
      ]
    }
    osProfile: {
      computerName: '${name}${format('{0:D2}', i + 1)}'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: !empty(windowsConfiguration) ? windowsConfiguration : null
      linuxConfiguration: !empty(linuxConfiguration) ? linuxConfiguration : null
      customData: !empty(customData) ? customData : null
    }
    hardwareProfile: {
      vmSize: size
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: '${name}${format('{0:D2}', i + 1)}${osDiskSuffix}'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osStorageAccountType
        }
      }
      dataDisks: [for (disk, index) in dataDisks: {
        name: '${name}${format('{0:D2}', i + 1)}${dataDiskSuffix}${format('{0:D3}', index + 1)}'
        diskSizeGB: disk.diskSizeGB
        lun: index
        caching: disk.caching
        createOption: 'Empty'
        managedDisk: {
          storageAccountType: disk.storageAccountType
        }
      }]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
    licenseType: !empty(licenseType) ? licenseType : null
  }
}]

resource extension_monitoring 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, instanceCount): if (!empty(diagnosticLogAnalyticsWorkspaceId)) {
  parent: virtualMachine[i]
  dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword) ? [
    extension_joinDomain
  ] : []
  name: 'Microsoft.EnterpriseCloud.Monitoring'
  location: location
  properties: {
    publisher: 'Microsoft.EnterpriseCloud.Monitoring'
    type: 'MicrosoftMonitoringAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    settings: !empty(diagnosticLogAnalyticsWorkspaceId) ? {
      workspaceId: reference(diagnosticLogAnalyticsWorkspaceId, '2015-03-20').customerId
    } : null
    protectedSettings: !empty(diagnosticLogAnalyticsWorkspaceId) ? {
      workspaceKey: listKeys(diagnosticLogAnalyticsWorkspaceId, '2015-03-20').primarySharedKey
    } : null
  }
}]

resource extension_depAgent 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, instanceCount): if (!empty(diagnosticLogAnalyticsWorkspaceId)) {
  parent: virtualMachine[i]
  dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword) ? [
    extension_joinDomain
    extension_monitoring
  ] : [
    extension_monitoring
  ]
  name: 'DependencyAgentWindows'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: 'DependencyAgentWindows'
    typeHandlerVersion: '9.5'
    autoUpgradeMinorVersion: true
  }

}]

resource extension_guestHealth 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, instanceCount): if (!empty(diagnosticLogAnalyticsWorkspaceId)) {
  parent: virtualMachine[i]
  dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword) ? [
    extension_joinDomain
    extension_depAgent
  ] : [
    extension_depAgent
  ]
  name: 'GuestHealthWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor.VirtualMachines.GuestHealth'
    type: 'GuestHealthWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}]

resource extension_azureMonitorWindowsAgent 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, instanceCount): if (!empty(diagnosticLogAnalyticsWorkspaceId)) {
  parent: virtualMachine[i]
  dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword) ? [
    extension_joinDomain
    extension_guestHealth
  ] : [
    extension_guestHealth
  ]
  name: 'AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}]

resource extension_antimalware 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, instanceCount): if (!empty(antiMalwareConfiguration)) {
  parent: virtualMachine[i]
  dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword) ? [
    extension_joinDomain
  ] : []
  name: 'IaaSAntimalware'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: antiMalwareConfiguration
  }
}]

resource extension_joinDomain 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, instanceCount): if (!empty(domainJoinSettings) && !empty(domainJoinPassword)) {
  parent: virtualMachine[i]
  name: 'JoinDomain'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainJoinSettings.domainToJoin
      oUPath: domainJoinSettings.ouPath
      user: '${domainJoinSettings.domainToJoin}\\${domainJoinSettings.domainJoinUser}'
      restart: 'true'
      options: 3 // Join Domain and Create Computer Account
    }
    protectedSettings: {
      password: domainJoinPassword
    }
  }
}]

resource extension_dsc 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [for i in range(0, instanceCount): if (!empty(dscConfiguration)) {
  parent: virtualMachine[i]
  dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword) ? [
    extension_joinDomain
  ] : []
  name: 'Microsoft.Powershell.DSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.83'
    autoUpgradeMinorVersion: true
    settings: dscConfiguration
  }
}]

resource lock 'Microsoft.Authorization/locks@2017-04-01' = [for i in range(0, instanceCount): if (resourceLock != 'NotSpecified') {
  scope: virtualMachine[i]
  name: toLower('${name}${format('{0:D2}', i + 1)}${lockSuffix}')
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}]

@description('The name of the deployed virtual machines.')
output name array = [for i in range(0, instanceCount): virtualMachine[i].name]

@description('The resource ID of the deployed virtual machines.')
output resourceId array = [for i in range(0, instanceCount): virtualMachine[i].id]
