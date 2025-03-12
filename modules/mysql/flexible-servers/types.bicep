@export()
@description('The type of Entra ID identity used for the MySQL Server.')
type administratorType = {
  identityResourceId: string
  login: string
  sid: string
  tenantId: string
}
