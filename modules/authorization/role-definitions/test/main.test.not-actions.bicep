targetScope = 'subscription'

// Specify custom role definitions. Use a fully qualified name to refer to the scope
var roleDefinitions = [
  {
    roleName: 'Junior VM administrator role'
    roleDescription: 'This test template deploys a set of role definitions to a subscription allow write/contributor access to all Compute, except for SharedVM resources'
    actions: [
      'Microsoft.Compute/*' // Atleast 1 action must defined or validation will fail
    ]
    notActions: [
      'Microsoft.Compute/sharedVMExtensions/versions/write'
      'Microsoft.Compute/sharedVMExtensions/versions/delete'
      'Microsoft.Compute/sharedVMImages/write'
      'Microsoft.Compute/sharedVMImages/delete'
      'Microsoft.Compute/sharedVMExtensions/write'
      'Microsoft.Compute/sharedVMExtensions/delete'
      'Microsoft.Compute/sharedVMImages/versions/delete'
      'Microsoft.Compute/sharedVMImages/versions/replicate/action'
      'Microsoft.Compute/sharedVMImages/versions/write'
    ] // Note that notActions is only supported for subscription deployments
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
