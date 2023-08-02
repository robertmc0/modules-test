targetScope = 'subscription'

// The name of the custom role
var roleName = 'Test - Custom role'

// A brief description describing the custom role
var roleDescription = 'This role contains a set of action roles (Allow), and notAction roles (Not allowed)'

// Define role defintions
// Atleast one action must be defined. No less
var actions = [
  'microsoft.web/*/read'
  'microsoft.insights/*/read'
  'Microsoft.Web/sites/publish/Action'
  'Microsoft.Web/sites/slots/publish/Action'
  'Microsoft.Web/sites/config/list/action'
  'Microsoft.Compute/*'
]

var notActions = [
  'Microsoft.Compute/sharedVMExtensions/versions/write'
  'Microsoft.Compute/sharedVMExtensions/versions/delete'
  'Microsoft.Compute/sharedVMImages/write'
  'Microsoft.Compute/sharedVMImages/delete'
  'Microsoft.Compute/sharedVMExtensions/write'
  'Microsoft.Compute/sharedVMExtensions/delete'
  'Microsoft.Compute/sharedVMImages/versions/delete'
  'Microsoft.Compute/sharedVMImages/versions/replicate/action'
  'Microsoft.Compute/sharedVMImages/versions/write'
]

var dataActions = []

var notDataActions = []

var roleDefinitions = [
  {
    roleName: roleName
    roleDescription: roleDescription
    actions: actions
    notActions: notActions
    dataActions: dataActions
    notDataActions: notDataActions
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
