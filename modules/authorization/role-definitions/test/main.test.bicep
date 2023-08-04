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
    dataActions: [
      'Microsoft.AppPlatform/Spring/eurekaService/read'
      'Microsoft.AppPlatform/Spring/eurekaService/write'
      'Microsoft.AppPlatform/Spring/eurekaService/delete'
    ]
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

module customRoleActionsOnly '../main.bicep' = {
  name: 'custom_role'
  params: {
    roleName: roleDefinitionsActionsOnly[0].roleName
    roleDescription: roleDefinitionsActionsOnly[0].roleDescription
    actions: roleDefinitionsActionsOnly[0].actions
  }
}

module customRoleNotActions '../main.bicep' = {
  name: 'notActions-custom_role'
  params: {
    roleName: roleDefinitionsNotActions[0].roleName
    roleDescription: roleDefinitionsNotActions[0].roleDescription
    actions: roleDefinitionsNotActions[0].actions
    notActions: roleDefinitionsNotActions[0].notActions
  }
}

module customRoleDataActions '../main.bicep' = {
  name: 'dataActions-custom_role'
  params: {
    roleName: roleDefinitionsDataActions[0].roleName
    roleDescription: roleDefinitionsDataActions[0].roleDescription
    actions: roleDefinitionsDataActions[0].actions
    dataActions: roleDefinitionsDataActions[0].dataActions
  }
}

module customRoleNotDataActions '../main.bicep' = {
  name: 'notDataActions-custom_role'
  params: {
    roleName: roleDefinitionsNotDataActions[0].roleName
    roleDescription: roleDefinitionsNotDataActions[0].roleDescription
    actions: roleDefinitionsNotDataActions[0].actions
    notDataActions: roleDefinitionsNotDataActions[0].notDataActions
  }
}
