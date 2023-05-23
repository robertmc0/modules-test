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
resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${shortIdentifier}-tst-vnet1-${uniqueString(deployment().name, 'virtualNetworks', location)}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-inbound'
        properties: {
          addressPrefix: '10.1.1.0/24'
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
      {
        name: 'snet-outbound'
        properties: {
          addressPrefix: '10.1.2.0/24'
          delegations: [
            {
              name: 'Microsoft.Network.dnsResolvers'
              properties: {
                serviceName: 'Microsoft.Network/dnsResolvers'
              }
            }
          ]
        }
      }
    ]
  }
}

resource dnsResolver 'Microsoft.Network/dnsResolvers@2022-07-01' = {
  name: '${shortIdentifier}-tst-dns-res-${uniqueString(deployment().name, 'dnsResolvers', location)}'
  location: location
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource dnsResolverInboundEndpoint 'Microsoft.Network/dnsResolvers/inboundEndpoints@2022-07-01' = {
  parent: dnsResolver
  name: '${dnsResolver.name}-dnsinbound'
  location: location
  properties: {
    ipConfigurations: [
      {
        privateIpAllocationMethod: 'Dynamic'
        subnet: {
          id: '${vnet.id}/subnets/snet-inbound'
        }
      }
    ]
  }
}

resource dnsResolverOutboundEndpoint 'Microsoft.Network/dnsResolvers/outboundEndpoints@2022-07-01' = {
  parent: dnsResolver
  name: '${dnsResolver.name}-dnsoutbound'
  location: location
  properties: {
    subnet: {
      id: '${vnet.id}/subnets/snet-outbound'
    }
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module dnsFwdRuleset '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-dns-forwarding-ruleset'
  dependsOn: [
    dnsResolverOutboundEndpoint
  ]
  params: {
    name: '${shortIdentifier}-tst-dns-fwd-${uniqueString(deployment().name, 'dnsFwdRuleset', location)}'
    virtualNetworkId: vnet.id
    outboundEndpointId: '${dnsResolver.id}/outboundEndpoints/${dnsResolver.name}-dnsoutbound'
    dnsFwdRules: [
      {
        name: 'Contoso'
        domainName: 'contoso.com.'
        targetDnsServers: [
          {
            ipAddress: '1.1.1.1'
            port: 53
          }
          {
            ipAddress: '1.1.1.2'
            port: 53
          }
        ]
      }
    ]
    location: location
    resourceLock: 'CanNotDelete'
  }
}
