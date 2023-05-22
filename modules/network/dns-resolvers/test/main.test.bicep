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

/*======================================================================
TEST EXECUTION
======================================================================*/
module privateDnsResolver '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-private-dns-resolver'
  params: {
    name: '${shortIdentifier}-tst-nw-${uniqueString(deployment().name, 'dnsResolver', location)}'
    virtualNetworkResourceName: vnet.name
    location: location
    resourceLock: 'CanNotDelete'
  }
}
