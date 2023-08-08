metadata name = 'FortiGate Active Active Module'
metadata description = 'This module deploys a FortiGate Network Virtual Appliance with an active-active architecture'
metadata owner = 'Arinco'

@description('Specifies the name prefix for the FortiGate resources.')
@minLength(1)
@maxLength(15)
param namePrefix string

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

@description('Optional. FortiGate image version. Only required when PAYG sku is selected.')
@allowed([
  '6.4.13'
  '7.0.12'
  '7.2.5'
  '7.4.0'
  'latest'
])
param imageVersion string = 'latest'

@description('Optional. Specifies the size of the virtual machine. Refer to https://learn.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#hardwareprofile for values.')
param size string = 'Standard_F2s'

@description('Specifies the name of the administrator account.')
param adminUsername string

@description('Specifies the password of the administrator account. Refer to https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachines?pivots=deployment-language-bicep#osprofile for password complexity requirements.')
@secure()
param adminPassword string

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

@description('The external (public) load balancer name.')
param externalLoadBalancerName string

@description('The external (public) load balancer public IP name.')
param externalLoadBalancerPublicIpName string

@description('The internal (private) load balancer name.')
param internalLoadBalancerName string

@description('The name of the network security group assoicated to the network interfaces.')
param nsgName string

@description('Subnet ID for the external (untrust) subnet.')
param externalSubnetId string

@description('Subnet ID for the internal (trust) subnet.')
param internalSubnetId string

@description('Optional. Enable accelerated networking on network interfaces.')
param acceleratedNetworking bool = true

@description('Optional. Enable diagnostic logging.')
param enableDiagnostics bool = false

@description('Optional. The name of log category groups that will be streamed.')
@allowed([
  'AllLogs'
])
param diagnosticLogCategoryGroupsToEnable array = [
  'AllLogs'
]

@description('Optional. The name of metrics that will be streamed.')
@allowed([
  'AllMetrics'
])
param diagnosticMetricsToEnable array = [
  'AllMetrics'
]

@description('Optional. Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely.')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 365

@description('Optional. Storage account resource id. Only required if enableDiagnostics is set to true.')
param diagnosticStorageAccountId string = ''

@description('Optional. Log analytics workspace resource id. Only required if enableDiagnostics is set to true.')
param diagnosticLogAnalyticsWorkspaceId string = ''

@description('Optional. Event hub authorization rule for the Event Hubs namespace. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubAuthorizationRuleId string = ''

@description('Optional. Event hub name. Only required if enableDiagnostics is set to true.')
param diagnosticEventHubName string = ''

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var externalLoadBalancerFrontEndName = toLower('${externalLoadBalancerName}-frntip')
var externalLoadBalancerProbeName = 'fortigate-tcp-8008-prbe'
var externalLoadBalancerBackEndPool = 'fortigate-bkpl'
var externalLoadBalancerFrontEndId = resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', externalLoadBalancerName, externalLoadBalancerFrontEndName)
var externalLoadBalancerBackEndId = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', externalLoadBalancerName, externalLoadBalancerBackEndPool)
var externalLoadBalancerProbeId = resourceId('Microsoft.Network/loadBalancers/probes', externalLoadBalancerName, externalLoadBalancerProbeName)
var externalLoadBalancerNatRuleSshFg1 = '50030-22-rule'
var externalLoadBalancerNatRuleSshFg2 = '50031-22-rule'
var externalLoadBalancerNatRuleAdminPermFg1 = '40030-443-rule'
var externalLoadBalancerNatRuleAdminPermFg2 = '40031-443-rule'
var internalLoadBalancerFrontEndName = toLower('${internalLoadBalancerName}-frntip')
var internalLoadBalancerBackEndPool = 'fortigate-bkpl'
var internalLoadBalancerProbeName = 'fortigate-tcp-8008-prbe'
var internalLoadBalancerBackEndId = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', internalLoadBalancerName, internalLoadBalancerBackEndPool)
var fortiGate1ExternalNicName = toLower('${namePrefix}01-ext-nic')
var fortiGate1InternalNicName = toLower('${namePrefix}01-int-nic')
var fortiGate2ExternalNicName = toLower('${namePrefix}02-ext-nic')
var fortiGate2InternalNicName = toLower('${namePrefix}02-int-nic')
var fortiGate1Name = toLower('${namePrefix}01')
var fortiGate2Name = toLower('${namePrefix}02')
var imageReference = {
  publisher: 'fortinet'
  offer: 'fortinet_fortigate-vm_v5'
  sku: 'fortinet_fg-vm'
  version: imageVersion
}
var osDiskSuffix = '-osdisk'
var dataDiskSuffix = '-disk-'
var externalSubnetName = last(split(externalSubnetId, '/'))
var externalSubnetSubId = split(externalSubnetId, '/')[2]
var externalSubnetResourceGroup = split(externalSubnetId, '/')[4]
var externalSubnetVnetName = split(externalSubnetId, '/')[8]
var externalSubnetAddressPrefix = externalSubnet.properties.addressPrefix
var externalSubnetAddressCidr = parseCidr(externalSubnetAddressPrefix)
var externalSubnetAddressLastIp = split(externalSubnetAddressCidr.lastUsable, '.')
var fortiGate1ExternalIpAddress = '${externalSubnetAddressLastIp[0]}.${externalSubnetAddressLastIp[1]}.${externalSubnetAddressLastIp[2]}.${int(last(externalSubnetAddressLastIp)) - 2}'
var fortiGate2ExternalIpAddress = '${externalSubnetAddressLastIp[0]}.${externalSubnetAddressLastIp[1]}.${externalSubnetAddressLastIp[2]}.${int(last(externalSubnetAddressLastIp)) - 1}'
var internalSubnetName = last(split(internalSubnetId, '/'))
var internalSubnetSubId = split(internalSubnetId, '/')[2]
var internalSubnetResourceGroup = split(internalSubnetId, '/')[4]
var internalSubnetVnetName = split(internalSubnetId, '/')[8]
var internalSubnetAddressPrefix = internalSubnet.properties.addressPrefix
var internalSubnetAddressCidr = parseCidr(internalSubnetAddressPrefix)
var internalSubnetAddressLastIp = split(internalSubnetAddressCidr.lastUsable, '.')
var fortiGateInternalLoadBalancerIpAddress = '${internalSubnetAddressLastIp[0]}.${internalSubnetAddressLastIp[1]}.${internalSubnetAddressLastIp[2]}.${int(last(internalSubnetAddressLastIp)) - 3}'
var fortiGate1InternalIpAddress = '${internalSubnetAddressLastIp[0]}.${internalSubnetAddressLastIp[1]}.${internalSubnetAddressLastIp[2]}.${int(last(internalSubnetAddressLastIp)) - 2}'
var fortiGate2InternalIpAddress = '${internalSubnetAddressLastIp[0]}.${internalSubnetAddressLastIp[1]}.${internalSubnetAddressLastIp[2]}.${int(last(internalSubnetAddressLastIp)) - 1}'
var fortiGate1VmLockName = toLower('${fortiGate1Name}-${resourceLock}-lck')
var fortiGate2VmLockName = toLower('${fortiGate2Name}-${resourceLock}-lck')
var externalLoadBalancerPublicIpDiagnosticsName = toLower('${externalLoadBalancerPublicIp.name}-dgs')
var diagnosticsLogs = [for categoryGroup in diagnosticLogCategoryGroupsToEnable: {
  categoryGroup: categoryGroup
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]
var diagnosticsMetrics = [for metric in diagnosticMetricsToEnable: {
  category: metric
  timeGrain: null
  enabled: true
  retentionPolicy: {
    enabled: true
    days: diagnosticLogsRetentionInDays
  }
}]

resource externalVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  scope: resourceGroup(externalSubnetSubId, externalSubnetResourceGroup)
  name: externalSubnetVnetName
}

resource externalSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent: externalVirtualNetwork
  name: externalSubnetName
}

resource internalVirtualNetwork 'Microsoft.Network/virtualNetworks@2023-04-01' existing = {
  scope: resourceGroup(internalSubnetSubId, internalSubnetResourceGroup)
  name: internalSubnetVnetName
}

resource internalSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-04-01' existing = {
  parent: internalVirtualNetwork
  name: internalSubnetName
}

resource availabilitySet 'Microsoft.Compute/availabilitySets@2023-03-01' = if (!empty(availabilitySetConfiguration)) {
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

resource externalLoadBalancerPublicIp 'Microsoft.Network/publicIPAddresses@2023-04-01' = {
  name: externalLoadBalancerPublicIpName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  zones: availabilityZones
  properties: {
    publicIPAllocationMethod: 'static'
  }
}

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics) {
  scope: externalLoadBalancerPublicIp
  name: externalLoadBalancerPublicIpDiagnosticsName
  properties: {
    workspaceId: empty(diagnosticLogAnalyticsWorkspaceId) ? null : diagnosticLogAnalyticsWorkspaceId
    storageAccountId: empty(diagnosticStorageAccountId) ? null : diagnosticStorageAccountId
    eventHubAuthorizationRuleId: empty(diagnosticEventHubAuthorizationRuleId) ? null : diagnosticEventHubAuthorizationRuleId
    eventHubName: empty(diagnosticEventHubName) ? null : diagnosticEventHubName
    logs: diagnosticsLogs
    metrics: diagnosticsMetrics
  }
}

resource externalLoadBalancer 'Microsoft.Network/loadBalancers@2023-04-01' = {
  name: externalLoadBalancerName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: externalLoadBalancerFrontEndName
        properties: {
          publicIPAddress: {
            id: externalLoadBalancerPublicIp.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: externalLoadBalancerBackEndPool
      }
    ]
    loadBalancingRules: [
      {
        name: 'http-80-rule'
        properties: {
          frontendIPConfiguration: {
            id: externalLoadBalancerFrontEndId
          }
          backendAddressPool: {
            id: externalLoadBalancerBackEndId
          }
          probe: {
            id: externalLoadBalancerProbeId
          }
          protocol: 'Tcp'
          frontendPort: 80
          backendPort: 80
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
        }
      }
      {
        name: 'udp-10551-rule'
        properties: {
          frontendIPConfiguration: {
            id: externalLoadBalancerFrontEndId
          }
          backendAddressPool: {
            id: externalLoadBalancerBackEndId
          }
          probe: {
            id: externalLoadBalancerProbeId
          }
          protocol: 'Udp'
          frontendPort: 10551
          backendPort: 10551
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
        }
      }
    ]
    inboundNatRules: [
      {
        name: externalLoadBalancerNatRuleSshFg1
        properties: {
          frontendIPConfiguration: {
            id: externalLoadBalancerFrontEndId
          }
          protocol: 'Tcp'
          frontendPort: 50030
          backendPort: 22
          enableFloatingIP: false
        }
      }
      {
        name: externalLoadBalancerNatRuleAdminPermFg1
        properties: {
          frontendIPConfiguration: {
            id: externalLoadBalancerFrontEndId
          }
          protocol: 'Tcp'
          frontendPort: 40030
          backendPort: 443
          enableFloatingIP: false
        }
      }
      {
        name: externalLoadBalancerNatRuleSshFg2
        properties: {
          frontendIPConfiguration: {
            id: externalLoadBalancerFrontEndId
          }
          protocol: 'Tcp'
          frontendPort: 50031
          backendPort: 22
          enableFloatingIP: false
        }
      }
      {
        name: externalLoadBalancerNatRuleAdminPermFg2
        properties: {
          frontendIPConfiguration: {
            id: externalLoadBalancerFrontEndId
          }
          protocol: 'Tcp'
          frontendPort: 40031
          backendPort: 443
          enableFloatingIP: false
        }
      }
    ]
    probes: [
      {
        name: externalLoadBalancerProbeName
        properties: {
          protocol: 'Tcp'
          port: 8008
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource internalLoadBalancer 'Microsoft.Network/loadBalancers@2023-04-01' = {
  name: internalLoadBalancerName
  location: location
  tags: tags
  sku: {
    name: 'Standard'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: internalLoadBalancerFrontEndName
        properties: {
          privateIPAddress: fortiGateInternalLoadBalancerIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: internalSubnetId
          }
        }
        zones: availabilityZones
      }
    ]
    backendAddressPools: [
      {
        name: internalLoadBalancerBackEndPool
      }
    ]
    loadBalancingRules: [
      {
        name: 'all-rule'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', internalLoadBalancerName, internalLoadBalancerFrontEndName)
          }
          backendAddressPool: {
            id: internalLoadBalancerBackEndId
          }
          probe: {
            id: resourceId('Microsoft.Network/loadBalancers/probes', internalLoadBalancerName, internalLoadBalancerProbeName)
          }
          protocol: 'all'
          frontendPort: 0
          backendPort: 0
          enableFloatingIP: true
          idleTimeoutInMinutes: 5
        }
      }
    ]
    probes: [
      {
        name: internalLoadBalancerProbeName
        properties: {
          protocol: 'Tcp'
          port: 8008
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [
      {
        name: 'AZ-Allow-Inbound-Any-Any-Any-Any'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AZ-Allow-Outbound-Any-Any-Any-Any'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 105
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource fortiGate1NicExternal 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: fortiGate1ExternalNicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: fortiGate1ExternalIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: externalSubnetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: externalLoadBalancerBackEndId
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/inboundNatRules', externalLoadBalancer.name, externalLoadBalancerNatRuleSshFg1)
            }
            {
              id: resourceId('Microsoft.Network/loadBalancers/inboundNatRules', externalLoadBalancer.name, externalLoadBalancerNatRuleAdminPermFg1)
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource fortiGate1NicInternal 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: fortiGate1InternalNicName
  tags: tags
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: fortiGate1InternalIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: internalSubnetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: internalLoadBalancerBackEndId
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource fortiGate2NicExternal 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: fortiGate2ExternalNicName
  tags: tags
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: fortiGate2ExternalIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: externalSubnetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: externalLoadBalancerBackEndId
            }
          ]
          loadBalancerInboundNatRules: [
            {
              id: resourceId('Microsoft.Network/loadBalancers/inboundNatRules', externalLoadBalancer.name, externalLoadBalancerNatRuleSshFg2)
            }
            {
              id: resourceId('Microsoft.Network/loadBalancers/inboundNatRules', externalLoadBalancer.name, externalLoadBalancerNatRuleAdminPermFg2)
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource fortiGate2NicInternal 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: fortiGate2InternalNicName
  tags: tags
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAddress: fortiGate2InternalIpAddress
          privateIPAllocationMethod: 'Static'
          subnet: {
            id: internalSubnetId
          }
          loadBalancerBackendAddressPools: [
            {
              id: internalLoadBalancerBackEndId
            }
          ]
        }
      }
    ]
    enableIPForwarding: true
    enableAcceleratedNetworking: acceleratedNetworking
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

resource fortiGate1Vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: fortiGate1Name
  tags: tags
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  zones: availabilityZones
  plan: {
    name: imageReference.sku
    publisher: imageReference.publisher
    product: imageReference.offer
  }
  properties: {
    hardwareProfile: {
      vmSize: size
    }
    availabilitySet: !empty(availabilitySetConfiguration) ? {
      id: availabilitySet.id
    } : null
    osProfile: {
      computerName: fortiGate1Name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: '${namePrefix}01${osDiskSuffix}'
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          name: '${namePrefix}01${dataDiskSuffix}001'
          diskSizeGB: 30
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: fortiGate1NicExternal.id
        }
        {
          properties: {
            primary: false
          }
          id: fortiGate1NicInternal.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource fortiGate1VmLock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: fortiGate1Vm
  name: fortiGate1VmLockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource fortiGate2Vm 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: fortiGate2Name
  tags: tags
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  zones: availabilityZones
  plan: {
    name: imageReference.sku
    publisher: imageReference.publisher
    product: imageReference.offer
  }
  properties: {
    hardwareProfile: {
      vmSize: size
    }
    availabilitySet: !empty(availabilitySetConfiguration) ? {
      id: availabilitySet.id
    } : null
    osProfile: {
      computerName: fortiGate2Name
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: '${namePrefix}02${osDiskSuffix}'
        createOption: 'FromImage'
      }
      dataDisks: [
        {
          name: '${namePrefix}02${dataDiskSuffix}001'
          diskSizeGB: 30
          lun: 0
          createOption: 'Empty'
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: fortiGate2NicExternal.id
        }
        {
          properties: {
            primary: false
          }
          id: fortiGate2NicInternal.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource fortiGate2VmLock 'Microsoft.Authorization/locks@2020-05-01' = if (resourceLock != 'NotSpecified') {
  scope: fortiGate2Vm
  name: fortiGate2VmLockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the first FortiGate Network Virtual Appliance.')
output fortiGate1Name string = fortiGate1Vm.name

@description('The resource ID of the first FortiGate Network Virtual Appliance.')
output fortiGate1ResourceId string = fortiGate1Vm.id

@description('The name of the second FortiGate Network Virtual Appliance.')
output fortiGate2Name string = fortiGate2Vm.name

@description('The resource ID of the second FortiGate Network Virtual Appliance.')
output fortiGate2ResourceId string = fortiGate2Vm.id
