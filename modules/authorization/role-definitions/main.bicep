targetScope = 'subscription'

@description('The display name of the custom role to be deployed.')
param roleName string

@description('The description for the custom role to be deployed.')
param roleDescription string

@description('List of permissions for role actions.')
@minLength(1)
param actions array

@description('List of permissions for role not actions.')
param notActions array = []

@description('List of permissions for role data actions.')
param dataActions array = []

@description('List of permissions for role not data actions.')
param notDataActions array = []

//Bicep requires a role name to be in a form of a UUID. This generates a random UUID based on the assignable scope and permissions
var customRoleUUID = guid(subscription().subscriptionId, string(actions), string(notActions), string(dataActions), string(notDataActions))

resource customrole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: customRoleUUID
  properties: {
    assignableScopes: [
      '/subscriptions/${subscription().subscriptionId}'
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
