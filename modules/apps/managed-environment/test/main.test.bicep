/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/

targetScope = 'resourceGroup'

@description('The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST EXECUTION
======================================================================*/

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: '${shortIdentifier}-tst-law-${uniqueString(deployment().name, 'logAnalyticsWorkspace', location)}'
  location: location
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${shortIdentifier}-tst-appinsights-${uniqueString(deployment().name, 'appInsights', location)}'
  location: location
  kind: 'web'
  properties:{
   Application_Type: 'web'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-01-01' = {
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
          addressPrefix: '10.0.0.0/23'
        }
      }
    ]
  }
}

module containerAppManagedEnvironment '../main.bicep' = {
    name: '${uniqueString(deployment().name, location)}-capp-mgdenvt'
    params: {
     location: location
      publicNetworkAccess: 'Disabled'
      mtlsEnabled: false
      peerEncryptionEnabled: false
      isZoneRedundant: false
      tags: {
       Environment: 'Test'
      }
      name: '${uniqueString(deployment().name, location)}-capp-me'   
	  applicationInsights: {
	   ConnectionString: applicationInsights.properties.ConnectionString
	   InstrumentationKey: applicationInsights.properties.InstrumentationKey
      }
	  logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
       infrastructureResourceGroup: '${uniqueString(deployment().name, location)}-capp-infra-rg'
       resourceLock: 'CanNotDelete'
       vnetConfiguration: {
           infrastructureSubnetId: '${vnet.id}/subnets/default'
           internal: false
       }
    }
}