metadata name = 'Data collection rule association module'
metadata description = 'This module deploys Microsoft.Insights dataCollectionRuleAssociations'
metadata owner = 'Arinco'

@description('Required. The VM name for the DCR to associate with.')
param virtualMachineName string

@description('Required. The resource Id of the DCR to associate the VM to.')
param dataCollectionRuleId string

@description('Optional. A DCR endpoint to associate with the VM and DCR with. Only used if Log analytics sits behind a network firewall.')
param dataCollectionEndpointId string = ''

resource vmRef 'Microsoft.Compute/virtualMachines@2023-09-01' existing = {
  name: virtualMachineName
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' =
  if (!empty(dataCollectionRuleId)) {
    name: 'dce-association'
    scope: vmRef
    properties: {
      description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
      dataCollectionRuleId: dataCollectionRuleId
      dataCollectionEndpointId: (!empty(dataCollectionEndpointId)) ? dataCollectionEndpointId : null
    }
  }

@description('The resource Id for the DCR association.')
output resourceId string = association.id
