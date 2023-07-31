targetScope = 'subscription'

//Change to subscription for a subscription deployment
//targetScope = 'subscription'

// Specify custom role definitions. Use a fully qualified name to refer to the scope
var roleDefinitions = [
  //{
  //  scopeId: 'mgmtgroup'
  //  scopeType: 'managementGroup'
  //  roleName: 'Custom Role Name'
  //  roleDescription: 'This is a description for the custom role definition'
  //  actions: [
  //    'microsoft.web/*/read'
  //    'microsoft.insights/*/read'
  //  ]
  //  notActions: []
  //  dataActions: []
  //  notDataActions: []
  //}
  {
    roleName: 'App Insights Configuration Reader'
    roleDescription: 'Allow read access Application Insights and Web configuration, including data stream'
    actions: [
      'microsoft.web/*/read'
      'microsoft.insights/*/read'
      'Microsoft.Web/sites/publish/Action'
      'Microsoft.Web/sites/slots/publish/Action'
      'Microsoft.Web/sites/config/list/action'
    ]
    notActions: []
    dataActions: []
    notDataActions: []
  }
]

module customRole '../main.bicep' = [for i in range(0, length(roleDefinitions)): {
  name: '${i}-custom_role'
  params: {
    roleName: roleDefinitions[i].roleName
    roleDescription: roleDefinitions[i].roleDescription
    actions: roleDefinitions[i].actions
    notActions: roleDefinitions[i].notActions
    dataActions: roleDefinitions[i].dataActions
    notDataActions: roleDefinitions[i].notDataActions
  }
}]
