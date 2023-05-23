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

module privateDnsResolver '../../dns-resolvers/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-private-dns-resolver'
  params: {
    name: '${shortIdentifier}-tst-dns-res-${uniqueString(deployment().name, 'dnsResolver', location)}'
    virtualNetworkId: vnet.id
    location: location
    resourceLock: 'CanNotDelete'
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module dnsFwdRuleset '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-dns-forwarding-ruleset'
  params: {
    name: '${shortIdentifier}-tst-dns-fwd-${uniqueString(deployment().name, 'dnsFwdRuleset', location)}'
    virtualNetworkId: vnet.id
    outboundEndpointId: '${privateDnsResolver.outputs.resourceid}/outboundEndpoints/${privateDnsResolver.outputs.name}-dnsoutbound'
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
