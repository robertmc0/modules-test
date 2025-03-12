metadata name = 'VPN Sites Module'
metadata description = 'This module deploys Microsoft.Network vpnSites'
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

@description('A list of address blocks reserved for this virtual network in CIDR notation.')
param addressPrefixes array

@description('Name of the device Vendor.')
param deviceVendor string

@description('Virtual WAN resource ID.')
param virtualWanId string

@description('List of all VPN site links.')
@metadata({
  name: 'The name of the resource that is unique within a resource group. This name can be used to access the resource.'
  ipAddress: 'The ip-address for the vpn-site-link.'
  fqdn: 'The fqdn for the vpn-site-link.'
  linkProviderName: 'Name of the link provider.'
  linkSpeedInMbps: 'Link speed.'

  bgpProperties: {
    asn: 'The BGP speaker\'s ASN.'
    bgpPeeringAddress: 'The BGP peering address and BGP identifier of this BGP speaker.'
  }
})
param vpnSiteLinks array

@description('Optional. Specify the type of resource lock.')
@allowed([
  'NotSpecified'
  'ReadOnly'
  'CanNotDelete'
])
param resourceLock string = 'NotSpecified'

var lockName = toLower('${vpnSite.name}-${resourceLock}-lck')

resource vpnSite 'Microsoft.Network/vpnSites@2022-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressPrefixes
    }
    deviceProperties: {
      deviceVendor: deviceVendor
    }
    virtualWan: {
      id: virtualWanId
    }
    vpnSiteLinks: [
      for siteLink in vpnSiteLinks: {
        name: siteLink.name
        properties: {
          ipAddress: siteLink.?ipAddress ?? null
          fqdn: siteLink.?fqdn ?? null
          linkProperties: {
            linkProviderName: siteLink.linkProviderName
            linkSpeedInMbps: siteLink.linkSpeedInMbps
          }
          bgpProperties: siteLink.?bgpProperties ?? null
        }
      }
    ]
  }
}

resource lock 'Microsoft.Authorization/locks@2017-04-01' = if (resourceLock != 'NotSpecified') {
  scope: vpnSite
  name: lockName
  properties: {
    level: resourceLock
    notes: (resourceLock == 'CanNotDelete')
      ? 'Cannot delete resource or child resources.'
      : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed VPN site.')
output name string = vpnSite.name

@description('The resource ID of the deployed VPN site.')
output resourceId string = vpnSite.id
