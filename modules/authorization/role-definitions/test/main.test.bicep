/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/

targetScope = 'subscription'

var roleDefinitionsActionsOnly = [
  {
    roleName: 'Test role - Actions only role'
    roleDescription: 'This is a sample role that will provide granular access to view to Web app configurations and data stream, but no write access'
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

var roleDefinitionsNotActions = [
  {
    roleName: 'Test role - Actions and Not Actions role'
    roleDescription: 'This is a sample role which grants all access to Microsoft.Compute permissions excluding specific compoments specified in notActions'
    actions: [
      'Microsoft.Compute/*'
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
    ]
    dataActions: []
    notDataActions: []
  }
]

var roleDefinitionsDataActions = [
  {
    roleName: 'Test role - Actions and Data Actions role'
    roleDescription: 'This is a sample role that grants access read permissions OperationalInsights, as well as allow DataActions for AppPlatform'
    actions: [
      'Microsoft.OperationalInsights/clusters/read'
      'Microsoft.OperationalInsights/operations/read'
      'microsoft.operationalinsights/operations/read'
    ]
    notActions: []
    dataActions: [
      'Microsoft.AppPlatform/Spring/eurekaService/read'
      'Microsoft.AppPlatform/Spring/eurekaService/write'
      'Microsoft.AppPlatform/Spring/eurekaService/delete'
    ]
    notDataActions: []
  }
]

var roleDefinitionsNotDataActions = [
  {
    roleName: 'Test role - Actions and Not Actions role'
    roleDescription: 'This is a sample role that grants access read permissions OperationalInsights, disallows write and delete data actions for AppPlatform'
    actions: [
      'Microsoft.OperationalInsights/clusters/read'
      'Microsoft.OperationalInsights/operations/read'
      'microsoft.operationalinsights/operations/read'
    ]
    notActions: []
    dataActions: []
    notDataActions: [
      'Microsoft.AppPlatform/Spring/eurekaService/write'
      'Microsoft.AppPlatform/Spring/eurekaService/delete'
    ]
  }
]

/*======================================================================
TEST PREREQUISITES
======================================================================*/

// N/A - Role definitions are deployed directly onto a subscription itself and does not require resource dependencies

/*======================================================================
TEST EXECUTION
======================================================================*/

module customRoleActionsOnly '../main.bicep' = [for i in range(0, length(roleDefinitionsActionsOnly)): {
  name: '${i}-custom_role'
  params: {
    roleName: roleDefinitionsActionsOnly[i].roleName
    roleDescription: roleDefinitionsActionsOnly[i].roleDescription
    actions: roleDefinitionsActionsOnly[i].actions
    notActions: roleDefinitionsActionsOnly[i].notActions
    dataActions: roleDefinitionsActionsOnly[i].dataActions
    notDataActions: roleDefinitionsActionsOnly[i].notDataActions
  }
}]

module customRoleNotActions '../main.bicep' = [for i in range(0, length(roleDefinitionsNotActions)): {
  name: '${i}-notActions-custom_role'
  params: {
    roleName: roleDefinitionsNotActions[i].roleName
    roleDescription: roleDefinitionsNotActions[i].roleDescription
    actions: roleDefinitionsNotActions[i].actions
    notActions: roleDefinitionsNotActions[i].notActions
    dataActions: roleDefinitionsNotActions[i].dataActions
    notDataActions: roleDefinitionsNotActions[i].notDataActions
  }
}]

module customRoleDataActions '../main.bicep' = [for i in range(0, length(roleDefinitionsDataActions)): {
  name: '${i}-dataActions-custom_role'
  params: {
    roleName: roleDefinitionsDataActions[i].roleName
    roleDescription: roleDefinitionsDataActions[i].roleDescription
    actions: roleDefinitionsDataActions[i].actions
    notActions: roleDefinitionsDataActions[i].notActions
    dataActions: roleDefinitionsDataActions[i].dataActions
    notDataActions: roleDefinitionsDataActions[i].notDataActions
  }
}]

module customRoleNotDataActions '../main.bicep' = [for i in range(0, length(roleDefinitionsNotDataActions)): {
  name: '${i}-notDataActions-custom_role'
  params: {
    roleName: roleDefinitionsNotDataActions[i].roleName
    roleDescription: roleDefinitionsNotDataActions[i].roleDescription
    actions: roleDefinitionsNotDataActions[i].actions
    notActions: roleDefinitionsNotDataActions[i].notActions
    dataActions: roleDefinitionsNotDataActions[i].dataActions
    notDataActions: roleDefinitionsNotDataActions[i].notDataActions
  }
}]
