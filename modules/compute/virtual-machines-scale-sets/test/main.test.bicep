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

param customData string = loadFileAsBase64('main.test.cloud-init.yml')

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

/*======================================================================
TEST EXECUTION
======================================================================*/
module vmssMinimum '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-min-vmss'
  params: {
    name: '${shortIdentifier}-tst-vmss-min-${uniqueString(deployment().name, 'virtualMachineScaleSet', location)}'
    location: location
    size: 'Standard_D2s_v3'
    osDiskType: 'Premium_LRS'
    networkInterfaceName: '${shortIdentifier}-tst-vmss-min-${uniqueString(deployment().name, 'virtualMachineScaleSet', location)}-nic'
    computerNamePrefix: '${shortIdentifier}-tst-vmss-'
    adminUsername: 'azureuser'
    adminPassword: vmPassword
    subnetResourceId: '${vnet.id}/subnets/default'
    imageReference: {
      publisher: 'canonical'
      offer: '0001-com-ubuntu-server-focal'
      sku: '20_04-lts'
      version: 'latest'
    }
  }
}

module vmss '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-vmss'
  params: {
    name: '${shortIdentifier}-tst-vmss-${uniqueString(deployment().name, 'virtualMachineScaleSet', location)}'
    location: location
    size: 'Standard_D2s_v3'
    osDiskType: 'Premium_LRS'
    networkInterfaceName: '${shortIdentifier}-tst-vmss-${uniqueString(deployment().name, 'virtualMachineScaleSet', location)}-nic'
    computerNamePrefix: '${shortIdentifier}-tst-vmss-'
    adminUsername: 'azureuser'
    adminPassword: vmPassword
    subnetResourceId: '${vnet.id}/subnets/default'
    imageReference: {
      publisher: 'canonical'
      offer: '0001-com-ubuntu-server-jammy'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    customData: customData
    capacity: 2
    upgradePolicyMode: 'Automatic'
    scaleInPolicy: {
      rules: [
        'OldestVM'
      ]
    }
    enableSecurityProfile: true
    encryptionAtHost: true
    securityType: 'TrustedLaunch'
    secureBootEnabled: true
    vTpmEnabled: true
  }
}
