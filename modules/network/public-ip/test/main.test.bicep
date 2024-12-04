param location string = resourceGroup().location
var apimSku = 'Developer'
var virtualNetworkType = 'None'
var ipDnsName = 'examplecloudapp'

module logAnalyticsWorkspace '../../../operational-insights/workspaces/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-la'
  params: {
    name: '${uniqueString(deployment().name, location)}-la'
    location: location
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${uniqueString(deployment().name, location)}-appi'
  location: location
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
  }
  kind: 'web'
}

module publicIp '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-pip'
  params: {
    location: location
    name: '${uniqueString(deployment().name, location)}-pip'
    dnsNameLabel: ipDnsName
  }
}

module apiManagementService '../../../api-management/service/main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-apim-02'
  params: {
    name: '${uniqueString(deployment().name, location)}-apim-02'
    location: location
    sku: apimSku
    systemAssignedIdentity: true
    minApiVersion: '2019-12-01'
    skuCount: 1
    loggerHttpCorrelationProtocol: 'W3C'
    publisherEmail: 'drew.robson@arinco.com.au'
    publisherName: 'Arinco'
    applicationInsightsId: applicationInsights.id
    publicIpAddressId: virtualNetworkType != 'None' ? publicIp.outputs.resourceId : ''
  }
}
