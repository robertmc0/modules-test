targetScope = 'managementGroup'

//Change to subscription for a subscription deployment
//targetScope = 'subscription'

@description('The value that defines whether the role assignment will be deployed to a subscription or a management group.')
param scopeType string

@description('The display name of the custom role to be deployed.')
param roleName string

@description('The description for the custom role to be deployed.')
param roleDescription string

@description('The target id of the deployment scope.')
param scopeId string

@description('List of permissions for role actions.')
param actions array

@description('List of permissions for role not actions.')
param notActions array

@description('List of permissions for role data actions.')
param dataActions array

@description('List of permissions for role not data actions.')
param notDataActions array

//Bicep requires a role name to be in a form of a UUID. This generates a random UUID based on the assignable scope and permissions
var customRoleUUID = guid(scopeId, string(actions), string(notActions), string(dataActions), string(notDataActions))

resource customrole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: customRoleUUID
  properties: {
    assignableScopes: [
      (scopeType == 'subscription' ? '/subscriptions/${scopeId}' : '/providers/Microsoft.Management/managementGroups/${scopeId}')
    ]
    description: roleDescription
    permissions: [
      {
        actions: actions
        notActions: notActions
        dataActions: dataActions
        notDataActions: notDataActions
      }
    ]
    roleName: roleName
    type: 'customRole'

  }
}
