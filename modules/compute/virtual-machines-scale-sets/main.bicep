metadata name = 'Virtual Machine Scale Sets Module'
metadata description = 'This module deploys Microsoft.Compute virtualMachineScaleSets'
metadata owner = 'Arinco'

@description('The resource name.')
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

@description('The VM size that you choose that determines factors such as processing power, memory, and storage capacity.')
param size string

@description('Specifies the storage account type for the os managed disk.')
@allowed([
  'Premium_LRS'
  'Premium_ZRS'
  'StandardSSD_LRS'
  'StandardSSD_ZRS'
  'Standard_LRS'
])
param osDiskType string

@description('The network interface name.')
param networkInterfaceName string

@description('Specifies the computer name prefix for all of the virtual machines in the scale set. Computer name prefixes must be 1 to 15 characters long.')
@minLength(1)
@maxLength(15)
param computerNamePrefix string

@secure()
@description('Specifies the name of the administrator account.')
param adminUsername string

@secure()
@description('Specifies the password of the administrator account. Refer to article for password requirements https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachinescalesets?pivots=deployment-language-bicep#virtualmachinescalesetosprofile.')
param adminPassword string

@description('Resource ID of the virtual machine scale set subnet.')
param subnetResourceId string

@description('Optional. Specifies the number of virtual machines in the scale set.')
param capacity int = 1

@description('Specifies information about the image to use. Refer to https://learn.microsoft.com/en-us/azure/virtual-machines/windows/cli-ps-findimage for values.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachinescalesets?pivots=deployment-language-bicep#imagereference'
  example: {
    publisher: 'string'
    offer: 'string'
    sku: 'string'
    version: 'string'
  }
})
param imageReference object

@description('Optional. Specifies the mode of an upgrade to virtual machines in the scale set.')
@allowed([
  'Automatic'
  'Manual'
  'Rolling'
])
param upgradePolicyMode string = 'Manual'

@description('Optional. Specifies a base-64 encoded string of custom data. The base-64 encoded string is decoded to a binary array that is saved as a file on the Virtual Machine. The maximum length of the binary array is 65535 bytes.')
param customData string = ''

@description('Optional. Specifies the orchestration mode for the virtual machine scale set.')
@allowed([
  'Flexible'
  'Uniform'
])
param orchestrationMode string = 'Uniform'

@description('Optional. Specifies the policies applied when scaling in Virtual Machines in the Virtual Machine Scale Set.')
@metadata({
  forceDeletion: 'This property allows you to specify if virtual machines chosen for removal have to be force deleted when a virtual machine scale set is being scaled-in. Allowed values are "true" or "false".'
  rules: [
    'The rules to be followed when scaling-in a virtual machine scale set. Allowed values are "Default", "NewestVM", "OldestVM".'
  ]
})
param scaleInPolicy object = {
  rules: [
    'Default'
  ]
}

@description('Optional. Specifies whether the Virtual Machine Scale Set should be overprovisioned.')
param overprovision bool = false

@description('Optional. Fault Domain count for each placement group.')
param platformFaultDomainCount int = 1

@description('Optional. A list of availability zones denoting the zone in which the virtual machine scale set should be deployed.')
@allowed([
  '1'
  '2'
  '3'
])
param availabilityZones array = []

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

var lockName = toLower('${virtualMachineScaleSet.name}-${resourceLock}-lck')

var securityProfileSettings = {
  encryptionAtHost: encryptionAtHost
  securityType: securityType
  uefiSettings: {
    secureBootEnabled: secureBootEnabled
    vTpmEnabled: vTpmEnabled
  }
}

resource virtualMachineScaleSet 'Microsoft.Compute/virtualMachineScaleSets@2024-03-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: size
    capacity: capacity
  }
  zones: availabilityZones
  properties: {
    orchestrationMode: orchestrationMode
    scaleInPolicy: scaleInPolicy
    overprovision: overprovision
    platformFaultDomainCount: platformFaultDomainCount
    upgradePolicy: {
      mode: upgradePolicyMode
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: computerNamePrefix
        adminUsername: adminUsername
        adminPassword: adminPassword
        customData: customData
      }
      storageProfile: {
        imageReference: imageReference
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: osDiskType
          }
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: networkInterfaceName
            properties: {
              primary: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    primary: true
                    subnet: {
                      id: subnetResourceId
                    }
                  }
                }
              ]
            }
          }
        ]
      }
      securityProfile: enableSecurityProfile ? securityProfileSettings : {}
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
    }
  }
}

resource lock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: virtualMachineScaleSet
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed virtual machine scale set.')
output name string = virtualMachineScaleSet.name

@description('The resource ID of the deployed virtual machine scale set.')
output resourceId string = virtualMachineScaleSet.id
