metadata name = 'Virtual Machines Module'
metadata description = 'This module deploys Microsoft.Compute virtualMachines'
metadata owner = 'Arinco'

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

@description('Specifies information about the image to use. Refer to https://learn.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage for values.')
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

@description('Optional. Set to true to automatically assign an AZ based on instance index.')
param autoAssignAvailabilityZones bool = false

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

@description('Optional. Specifies Windows operating system settings on the virtual machine.')
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
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
])
param osStorageAccountType string

@description('Optional. Specifies the parameters that are used to add a data disk to a virtual machine.')
@metadata({
  storageAccountType: 'Specifies the storage account type for the managed disk.'
  diskSizeGB: 'Specifies the size of an empty data disk in gigabytes.'
  caching: 'Specifies the caching requirements. Accepted values are "None", "ReadOnly" or "ReadWrite".'
  createOption: 'Specifies how the virtual machine should be created. Accepted values are "Attach", "Empty" or "FromImage".'
  id: 'Optional, only needed when "createOption" are "Attach" then need to define the existing data disk by resource id.'
})
param dataDisks array = []

@description('Resource ID of the virtual machine subnet.')
param subnetResourceId string

@description('Optional. Specifies that the image or disk that is being used was licensed on-premises. Accepted values "Windows_Client", "Windows_Server", "RHEL_BYOS" or "SLES_BYOS".')
param licenseType string = ''

@description('Optional. DCR id to associate VM for AMA agent. Only required to enable VM Diagnostics.')
param dataCollectionRuleId string = ''

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

@description('Optional. Enable AAD login extension for VM.')
param enableAadLogin bool = false

@description('Optional. Enable Microsoft Intune for VM.')
param enableAadLoginWithIntune bool = false

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

@description('Optional. Enables the Security related profile settings for the virtual machine. Only supported on Gen 2 VMs.')
@metadata({
  doc: 'https://learn.microsoft.com/en-au/azure/virtual-machines/trusted-launch'
})
param enableSecurityProfile bool = false

@description('Optional. Enable the encryption for all the disks including Resource/Temp disk at host itself.')
param encryptionAtHost bool = true

@description('Optional. Specifies the SecurityType of the virtual machine. It has to be set to any specified value to enable UefiSettings.')
@allowed([
  'TrustedLaunch'
  'ConfidentialVM'
])
param securityType string = 'TrustedLaunch'

@description('Optional. Enable secure boot on the virtual machine.')
param secureBootEnabled bool = true

@description('Optional. Enable vTPM on the virtual machine.')
param vTpmEnabled bool = true

var securityProfileSettings = {
  encryptionAtHost: encryptionAtHost
  securityType: securityType
  uefiSettings: {
    secureBootEnabled: secureBootEnabled
    vTpmEnabled: vTpmEnabled
  }
}

var lockSuffix = '-lck'

var networkInterfaceSuffix = '-nic'

var osDiskSuffix = '-osdisk'

var dataDiskSuffix = '-disk-'

var identityType = systemAssignedIdentity
  ? (!empty(userAssignedIdentities) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
  : (!empty(userAssignedIdentities) ? 'UserAssigned' : 'None')

var identity = identityType != 'None'
  ? {
      type: identityType
      userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
    }
  : null

resource networkInterface 'Microsoft.Network/networkInterfaces@2022-07-01' = [
  for i in range(0, instanceCount): {
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
  }
]

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

resource virtualMachine 'Microsoft.Compute/virtualMachines@2023-09-01' = [
  for i in range(0, instanceCount): {
    dependsOn: [
      networkInterface
    ]
    name: '${name}${format('{0:D2}', i + 1)}'
    location: location
    tags: tags
    identity: identity
    zones: autoAssignAvailabilityZones ? [ string((i % 3) + 1) ] : availabilityZones
    properties: {
      availabilitySet: !empty(availabilitySetConfiguration)
        ? {
            id: availabilitySet.id
          }
        : null
      networkProfile: {
        networkInterfaces: [
          {
            #disable-next-line use-resource-id-functions
            id: az.resourceId(
              'Microsoft.Network/networkInterfaces',
              '${name}${format('{0:D2}', i + 1)}${networkInterfaceSuffix}'
            )
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
        dataDisks: [
          for (disk, index) in dataDisks: {
            name: (disk.createOption == 'Empty')
              ? '${name}${format('{0:D2}', i + 1)}${dataDiskSuffix}${format('{0:D3}', index + 1)}'
              : null
            diskSizeGB: (disk.createOption == 'Empty') ? disk.diskSizeGB : null
            lun: index
            caching: (disk.createOption == 'Empty') ? disk.caching : null
            createOption: disk.createOption
            managedDisk: {
              id: (disk.createOption == 'Attach') ? disk.id : null
              storageAccountType: !(disk.createOption == 'Attach') ? disk.storageAccountType : null
            }
          }
        ]
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
      securityProfile: enableSecurityProfile ? securityProfileSettings : {}
      licenseType: !empty(licenseType) ? licenseType : null
    }
  }
]

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = [
  for i in range(0, instanceCount): if (!empty(dataCollectionRuleId)) {
    name: 'dcr-association'
    scope: virtualMachine[i]
    properties: {
      description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
      dataCollectionRuleId: dataCollectionRuleId
    }
  }
]

resource extension_guestHealth 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [
  for i in range(0, instanceCount): if (!empty(dataCollectionRuleId)) {
    parent: virtualMachine[i]
    dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword)
      ? [
          extension_joinDomain
          extension_depAgent
        ]
      : [
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
  }
]

resource extension_azureMonitorAgent 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [
  for i in range(0, instanceCount): if (!empty(dataCollectionRuleId)) {
    parent: virtualMachine[i]
    dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword)
      ? [
          extension_joinDomain
          extension_guestHealth
          association
        ]
      : [
          extension_guestHealth
          association
        ]
    name: !empty(windowsConfiguration) || (empty(windowsConfiguration) && empty(linuxConfiguration))
      ? 'AzureMonitorWindowsAgent'
      : 'AzureMonitorLinuxAgent' // If both config are null, assume Windows
    location: location
    properties: {
      publisher: 'Microsoft.Azure.Monitor'
      type: !empty(windowsConfiguration) || (empty(windowsConfiguration) && empty(linuxConfiguration))
        ? 'AzureMonitorWindowsAgent'
        : 'AzureMonitorLinuxAgent' // If both config are null, assume Windows
      typeHandlerVersion: '1.0'
      autoUpgradeMinorVersion: true
    }
  }
]

resource extension_depAgent 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = [
  for i in range(0, instanceCount): if (!empty(dataCollectionRuleId)) {
    parent: virtualMachine[i]
    dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword)
      ? [
          extension_joinDomain
        ]
      : []
    name: 'DependencyAgentWindows'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
      type: 'DependencyAgentWindows'
      typeHandlerVersion: '9.10'
      autoUpgradeMinorVersion: true
    }
  }
]

resource extension_antimalware 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [
  for i in range(0, instanceCount): if (!empty(antiMalwareConfiguration)) {
    parent: virtualMachine[i]
    dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword)
      ? [
          extension_joinDomain
        ]
      : []
    name: 'IaaSAntimalware'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.Security'
      type: 'IaaSAntimalware'
      typeHandlerVersion: '1.3'
      autoUpgradeMinorVersion: true
      settings: antiMalwareConfiguration
    }
  }
]

resource extension_joinDomain 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [
  for i in range(0, instanceCount): if (!empty(domainJoinSettings) && !empty(domainJoinPassword)) {
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
  }
]

resource extension_aadLogin 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [
  for i in range(0, instanceCount): if (enableAadLogin) {
    parent: virtualMachine[i]
    name: 'AADLoginForWindows'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADLoginForWindows'
      typeHandlerVersion: '2.0'
      autoUpgradeMinorVersion: true
    }
  }
]

resource extension_aadLoginWithIntune 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [
  for i in range(0, instanceCount): if (enableAadLoginWithIntune) {
    parent: virtualMachine[i]
    dependsOn: [extension_azureMonitorAgent[i], extension_guestHealth[i], extension_depAgent[i]]
    name: 'AADLoginForWindowsWithIntune'
    location: location
    properties: {
      publisher: 'Microsoft.Azure.ActiveDirectory'
      type: 'AADLoginForWindows'
      typeHandlerVersion: '2.0'
      autoUpgradeMinorVersion: true
      settings: {
        mdmId: '0000000a-0000-0000-c000-000000000000'
      }
    }
  }
]

resource extension_dsc 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = [
  for i in range(0, instanceCount): if (!empty(dscConfiguration)) {
    parent: virtualMachine[i]
    dependsOn: !empty(domainJoinSettings) && !empty(domainJoinPassword)
      ? [
          extension_joinDomain
        ]
      : []
    name: 'Microsoft.Powershell.DSC'
    location: location
    properties: {
      publisher: 'Microsoft.Powershell'
      type: 'DSC'
      typeHandlerVersion: '2.83'
      autoUpgradeMinorVersion: true
      settings: dscConfiguration
    }
  }
]

resource lock 'Microsoft.Authorization/locks@2017-04-01' = [
  for i in range(0, instanceCount): if (resourceLock != 'NotSpecified') {
    scope: virtualMachine[i]
    name: toLower('${name}${format('{0:D2}', i + 1)}${lockSuffix}')
    properties: {
      level: resourceLock
      notes: (resourceLock == 'CanNotDelete')
        ? 'Cannot delete resource or child resources.'
        : 'Cannot modify the resource or child resources.'
    }
  }
]

@description('The name of the deployed virtual machines.')
output name array = [for i in range(0, instanceCount): virtualMachine[i].name]

@description('The resource ID of the deployed virtual machines.')
output resourceId array = [for i in range(0, instanceCount): virtualMachine[i].id]
