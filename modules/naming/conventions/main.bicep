metadata name = 'Naming Conventions Module'
metadata description = 'This module is used to create a naming convention for resources in Azure.'
metadata owner = 'Arinco'

targetScope = 'subscription'

@description('Company prefix.')
param companyPrefix string

@description('Deployment location.')
param location string

@description('Optional. Geo-location codes for resources.')
param geoLocationCodes object = {
  australiacentral: 'acl'
  australiacentral2: 'acl2'
  australiaeast: 'ae'
  australiasoutheast: 'ase'
  brazilsouth: 'brs'
  centraluseuap: 'ccy'
  canadacentral: 'cnc'
  canadaeast: 'cne'
  centralus: 'cus'
  eastasia: 'ea'
  eastus2euap: 'ecy'
  eastus: 'eus'
  eastus2: 'eus2'
  francecentral: 'frc'
  francesouth: 'frs'
  germanynorth: 'gn'
  germanywestcentral: 'gwc'
  centralindia: 'inc'
  southindia: 'ins'
  westindia: 'inw'
  japaneast: 'jpe'
  japanwest: 'jpw'
  koreacentral: 'krc'
  koreasouth: 'krs'
  northcentralus: 'ncus'
  northeurope: 'ne'
  norwayeast: 'nwe'
  norwaywest: 'nww'
  southafricanorth: 'san'
  southafricawest: 'saw'
  southcentralus: 'scus'
  swedencentral: 'sdc'
  swedensouth: 'sds'
  southeastasia: 'sea'
  switzerlandnorth: 'szn'
  switzerlandwest: 'szw'
  uaecentral: 'uac'
  uaenorth: 'uan'
  uksouth: 'uks'
  ukwest: 'ukw'
  westcentralus: 'wcus'
  westeurope: 'we'
  westus: 'wus'
  westus2: 'wus2'
  usdodcentral: 'udc'
  usdodeast: 'ude'
  usgovarizona: 'uga'
  usgoviowa: 'ugi'
  usgovtexas: 'ugt'
  usgovvirginia: 'ugv'
  chinanorth: 'bjb'
  chinanorth2: 'bjb2'
  chinaeast: 'sha'
  chinaeast2: 'sha2'
  germanycentral: 'gec'
  germanynortheast: 'gne'
}

@description('Optional. The name of the environment.')
param environment string = ''

@description('Optional. Short description of the application or service name.')
param descriptor string = '<descriptor>'

@description('Optional. The geo-location identifier used for all resources.')
@minLength(2)
@maxLength(4)
param locationIdentifier string = contains(geoLocationCodes, location)
  ? '${geoLocationCodes[toLower(location)]}'
  : location

var prefix = '${companyPrefix}-${locationIdentifier}${!empty(environment) ? '-${environment}' : ''}-${descriptor}'
var acrSuffix = 'cr'
var aciSuffix = 'ci'
var alertSuffix = 'alert'
var apimSuffix = 'apim'
var actionGroupSuffix = 'ag'
var appGatewaySuffix = 'agw'
var appGatewayPolicySuffix = 'waf'
var appInsightsSuffix = 'appi'
var appServicePlanSuffix = 'asp'
var aksSuffix = 'aks'
var autoAccountSuffix = 'aa'
var availabilitySetSuffix = 'avail'
var bastionSuffix = 'bas'
var budgetSuffix = 'bgt'
var cosmosDbSuffix = 'cosmos'
var ddosProtectionPlanSuffix = 'ddos'
var dnsResolverSuffix = 'dnspr'
var expressRouteCircuitSuffix = 'erc'
var externalLoadBalancerSuffix = 'lbe'
var firewallSuffix = 'afw'
var firewallPolicySuffix = 'afwp'
var frontDoorSuffix = 'afd'
var internalLoadBalancerSuffix = 'lbi'
var keyVaultSuffix = 'kv'
var localNetworkGatewaySuffix = 'lgw'
var logAnalyticsSuffix = 'log'
var logicAppSuffix = 'logic'
var mlWorkspaceSuffix = 'mlw'
var managedIdentitySuffix = 'id'
var networkInterfaceSuffix = 'nic'
var nsgSuffix = 'nsg'
var nsgFlowLogSuffix = 'flow'
var networkWatcherSuffix = 'nw'
var publicIpSuffix = 'pip'
var recoveryServicesVaultSuffix = 'rsv'
var resourceGroupSuffix = 'rg'
var routeTableSuffix = 'rt'
var sqlDbSuffix = 'sqldb'
var sqlServerSuffix = 'sql'
var storageAccountSuffix = 'st'
var trafficManagerSuffix = 'traf'
var virtualMachineSuffix = 'vm'
var virtualMachineScaleSetSuffix = 'vmss'
var vnetSuffix = 'vnet'
var vnetGatewaySuffix = 'vgw'
var vwanSuffix = 'vwan'
var vwanHubSuffix = 'vhub'
var webAppSuffix = 'app'

@description('Azure container registry (ACR) name.')
output acr object = {
  name: '${companyPrefix}${locationIdentifier}${!empty(environment) ? '${environment}' : ''}${descriptor}${acrSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: acrSuffix
}

@description('Azure Container Instance (ACI) name.')
output aci object = {
  name: '${prefix}-${aciSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: aciSuffix
}

@description('Azure Kubernetes Service (AKS) name.')
output alert object = {
  name: '${prefix}-${alertSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: alertSuffix
}

@description('API Management (APIM) name.')
output apim object = {
  name: '${prefix}-${apimSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: apimSuffix
}

@description('Action group name.')
output actionGroup object = {
  name: '${prefix}-${actionGroupSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: actionGroupSuffix
}

@description('Application Gateway name.')
output appGateway object = {
  name: '${prefix}-${appGatewaySuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: appGatewaySuffix
}

@description('Application Gateway WAF policy name.')
output appGatewayPolicy object = {
  name: '${prefix}-${appGatewayPolicySuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: appGatewayPolicySuffix
}

@description('Application Insights name.')
output appInsights object = {
  name: '${prefix}-${appInsightsSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: appInsightsSuffix
}

@description('App Service Plan name.')
output appServicePlan object = {
  name: '${prefix}-${appServicePlanSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: appServicePlanSuffix
}

@description('Azure Kubernetes Service (AKS) name.')
output aks object = {
  name: '${prefix}-${aksSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: aksSuffix
}

@description('Azure Automation Account name.')
output automationAccount object = {
  name: '${prefix}-${autoAccountSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: autoAccountSuffix
}

@description('Availability Set name.')
output availabilitySet object = {
  name: '${prefix}-${availabilitySetSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: availabilitySetSuffix
}

@description('Azure Bastion name.')
output bastion object = {
  name: '${prefix}-${bastionSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: bastionSuffix
}

@description('Budget name.')
output budget object = {
  name: '${replace(trim(subscription().displayName), ' ', '')}-${budgetSuffix}'
  suffix: budgetSuffix
}

@description('Azure Cosmos DB name.')
output cosmosDb object = {
  name: '${prefix}-${cosmosDbSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: cosmosDbSuffix
}

@description('DDoS Protection Plan name.')
output ddosProtectionPlan object = {
  name: '${prefix}-${ddosProtectionPlanSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: ddosProtectionPlanSuffix
}

@description('DNS Resolver name.')
output dnsResolver object = {
  name: '${prefix}-${dnsResolverSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: dnsResolverSuffix
}

@description('ExpressRoute Circuit name.')
output expressRouteCircuit object = {
  name: '${prefix}-${expressRouteCircuitSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: expressRouteCircuitSuffix
}

@description('External Load Balancer name.')
output externalLoadBalancer object = {
  name: '${prefix}-${externalLoadBalancerSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: externalLoadBalancerSuffix
}

@description('Firewall name.')
output firewall object = {
  name: '${prefix}-${firewallSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: firewallSuffix
}

@description('Firewall Policy name.')
output firewallPolicy object = {
  name: '${prefix}-${firewallPolicySuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: firewallPolicySuffix
}

@description('Front Door name.')
output frontDoor object = {
  name: '${prefix}-${frontDoorSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: frontDoorSuffix
}

@description('Function App name.')
output internalLoadBalancer object = {
  name: '${prefix}-${internalLoadBalancerSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: internalLoadBalancerSuffix
}

@description('Key Vault name.')
output keyVault object = {
  name: '${prefix}-${keyVaultSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: keyVaultSuffix
}

@description('Load Balancer name.')
output localNetworkGateway object = {
  name: '${prefix}-${localNetworkGatewaySuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: localNetworkGatewaySuffix
}

@description('Log Analytics name.')
output logAnalytics object = {
  name: '${prefix}-${logAnalyticsSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: logAnalyticsSuffix
}

@description('Logic App name.')
output logicApp object = {
  name: '${prefix}-${logicAppSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: logicAppSuffix
}

@description('Machine Learning Workspace name.')
output mlWorkspace object = {
  name: '${prefix}-${mlWorkspaceSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: mlWorkspaceSuffix
}

@description('Managed Identity name.')
output managedIdentity object = {
  name: '${prefix}-${managedIdentitySuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: managedIdentitySuffix
}

@description('Network Interface name.')
output networkInterface object = {
  name: '${prefix}-${networkInterfaceSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: networkInterfaceSuffix
}

@description('Network Security Group name.')
output nsg object = {
  name: '${prefix}-${nsgSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: nsgSuffix
}

@description('Network Security Group Flow Log name.')
output nsgFlowLog object = {
  name: '${prefix}-${nsgFlowLogSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: nsgFlowLogSuffix
}

@description('Network Watcher name.')
output networkWatcher object = {
  name: '${companyPrefix}-${locationIdentifier}-${networkWatcherSuffix}'
  location: locationIdentifier
  suffix: networkWatcherSuffix
}

@description('Public IP Address name.')
output publicIp object = {
  name: '${prefix}-${publicIpSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: publicIpSuffix
}

@description('Recovery Services Vault name.')
output recoveryServicesVault object = {
  name: '${prefix}-${recoveryServicesVaultSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: recoveryServicesVaultSuffix
}

@description('Resource Group name.')
output resourceGroup object = {
  name: '${prefix}-${resourceGroupSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: resourceGroupSuffix
}

@description('Route Table name.')
output routeTable object = {
  name: '${prefix}-${routeTableSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: routeTableSuffix
}

@description('SQL Database name.')
output sqlDb object = {
  name: '${prefix}-${sqlDbSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: sqlDbSuffix
}

@description('SQL Server name.')
output sqlServer object = {
  name: '${prefix}-${sqlServerSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: sqlServerSuffix
}

@description('Storage Account name.')
output storageAccount object = {
  name: '${companyPrefix}${locationIdentifier}${!empty(environment) ? '${environment}' : ''}${descriptor}${storageAccountSuffix}'
  suffix: storageAccountSuffix
}

@description('Traffic Manager name.')
output trafficManager object = {
  name: '${prefix}-${trafficManagerSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: trafficManagerSuffix
}

@description('Virtual Machine name.')
output virtualMachine object = {
  name: '${companyPrefix}${locationIdentifier}${!empty(environment) ? '${environment}' : ''}${descriptor}${virtualMachineSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: virtualMachineSuffix
}
@description('Virtual Machine Scale Set name.')
output virtualMachineScaleSet object = {
  name: '${companyPrefix}${locationIdentifier}${!empty(environment) ? '${environment}' : ''}${descriptor}${virtualMachineScaleSetSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: virtualMachineScaleSetSuffix
}
@description('Virtual Network name.')
output vnet object = {
  name: '${prefix}-${vnetSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: vnetSuffix
}

@description('Virtual Network Gateway name.')
output vnetGateway object = {
  name: '${prefix}-${vnetGatewaySuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: vnetGatewaySuffix
}

@description('Virtual WAN name.')
output vwan object = {
  name: '${prefix}-${vwanSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: vwanSuffix
}

@description('Virtual WAN Hub name.')
output vwanHub object = {
  name: '${prefix}-${vwanHubSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: vwanHubSuffix
}

@description('Web App name.')
output webApp object = {
  name: '${prefix}-${webAppSuffix}'
  prefix: companyPrefix
  location: locationIdentifier
  environment: environment
  descriptor: descriptor
  suffix: webAppSuffix
}
