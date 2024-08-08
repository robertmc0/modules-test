metadata name = 'Data collection rule association module'
metadata description = 'This module deploys Microsoft.Insights dataCollectionRuleAssociations'
metadata owner = 'Arinco'

@description('The geo-location where the resource lives.')
param location string

@description('Required. The VM name for the DCR to associate with.')
param virtualMachineName string

@description('Required. The resource Id of the DCR to associate the VM to.')
param dataCollectionRuleId string

@description('Optional. A DCR endpoint to associate with the VM and DCR with. Only used if Log analytics sits behind a network firewall.')
param dataCollectionEndpointId string = ''

@description('OS Type of the VM, either Windows, Linux or All')
@allowed([
  'Windows'
  'Linux'
  'All'
])
param kind string

resource vmRef 'Microsoft.Compute/virtualMachines@2023-09-01' existing = {
  name: virtualMachineName
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = if (!empty(dataCollectionRuleId)) {
  name: 'dcr-association'
  scope: vmRef
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
    dataCollectionRuleId: dataCollectionRuleId
    dataCollectionEndpointId: (!empty(dataCollectionEndpointId)) ? dataCollectionEndpointId : null
  }
}

resource extension_azureMonitorWindowsAgent 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = if (kind == 'Windows') {
  parent: vmRef
  name: 'AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

resource extension_AzureMonitorLinuxAgent 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = if (kind == 'Linux') {
  parent: vmRef
  name: 'AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
  }
}

@description('The resource Id for the DCR association.')
output resourceId string = association.id
