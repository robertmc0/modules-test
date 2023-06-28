targetScope = 'managementGroup'

//Change to subscription for a subscription deployment
//targetScope = 'subscription'

// Specify custom role definitions. Use a fully qualified name to refer to the scope
var roleDefinitions = [
  {
    scopeId: 'mgmtgroup'
    scopeType: 'managementGroup'
    roleName: 'Custom Role Name'
    roleDescription: 'This is a description for the custom role definition'
    actions: [
      'microsoft.web/*/read'
      'microsoft.insights/*/read'
    ]
    notActions: []
    dataActions: []
    notDataActions: []
  }
  //{
  //  scope: '01234567-0123-0123-0123-0123456789B'
  //  scopeType: 'subscription'
  //  roleName: 'App Insights Configuration Reader'
  //  roleDescription: 'This is a description for the custom role definition'
  //  actions: [
  //    'microsoft.web/*/read'
  //    'microsoft.insights/*/read'
  //  ]
  //  notActions: []
  //  dataActions: []
  //  notDataActions: []
  //}
]

module customRole '../main.bicep' = [for i in range(0, length(roleDefinitions)): {
  //scope: resourceGroup()
  name: '${i}-custom_role'
  params: {
    scopeType: roleDefinitions[i].scopeType
    roleName: roleDefinitions[i].roleName
    roleDescription: roleDefinitions[i].roleDescription
    actions: roleDefinitions[i].actions
    notActions: roleDefinitions[i].notActions
    dataActions: roleDefinitions[i].dataActions
    notDataActions: roleDefinitions[i].notDataActions
    scopeId: roleDefinitions[i].scopeId
  }
}]
