metadata name = 'Naming Conventions Module'
metadata description = 'This module is used to create a naming convention for resources in Azure.'
metadata owner = 'Arinco'

targetScope = 'subscription'

@description('Prefixes to set (in order) for the resource name.')
param prefixes array

@description('Suffixes to set (in order) for the resource name.')
param suffixes array

@description('Optional. Separator to use for the resource name, e.g. \'-\' or \'_\'.')
param separator string = '-'

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

@export()
type nameType = {
  name: string
  slug: string
}

@description('Optional. The geo-location identifier used for all resources.')
@minLength(2)
@maxLength(4)
param locationIdentifier string = contains(geoLocationCodes, location)
  ? '${geoLocationCodes[toLower(location)]}'
  : location

var prefix = join(prefixes, separator)
var suffix = join(suffixes, separator)
var baseName = toLower(replace('${prefix}${separator}${suffix}', '**location**', locationIdentifier))

var slugs = {
  acrSlug: 'cr'
  aciSlug: 'ci'
  alertSlug: 'alert'
  apimSlug: 'apim'
  actionGroupSlug: 'ag'
  appGatewaySlug: 'agw'
  appGatewayPolicySlug: 'waf'
  appInsightsSlug: 'appi'
  appServicePlanSlug: 'asp'
  aksSlug: 'aks'
  autoAccountSlug: 'aa'
  availabilitySetSlug: 'avail'
  bastionSlug: 'bas'
  budgetSlug: 'bgt'
  cosmosDbSlug: 'cosmos'
  ddosProtectionPlanSlug: 'ddos'
  dnsResolverSlug: 'dnspr'
  expressRouteCircuitSlug: 'erc'
  externalLoadBalancerSlug: 'lbe'
  firewallSlug: 'afw'
  firewallPolicySlug: 'afwp'
  frontDoorSlug: 'afd'
  internalLoadBalancerSlug: 'lbi'
  keyVaultSlug: 'kv'
  localNetworkGatewaySlug: 'lgw'
  logAnalyticsSlug: 'log'
  logicAppSlug: 'logic'
  mlWorkspaceSlug: 'mlw'
  managedIdentitySlug: 'id'
  networkInterfaceSlug: 'nic'
  nsgSlug: 'nsg'
  nsgFlowLogSlug: 'flow'
  networkWatcherSlug: 'nw'
  publicIpSlug: 'pip'
  recoveryServicesVaultSlug: 'rsv'
  resourceGroupSlug: 'rg'
  routeTableSlug: 'rt'
  sqlDbSlug: 'sqldb'
  sqlServerSlug: 'sql'
  storageAccountSlug: 'st'
  trafficManagerSlug: 'traf'
  virtualMachineSlug: 'vm'
  virtualMachineScaleSetSlug: 'vmss'
  vnetSlug: 'vnet'
  vnetGatewaySlug: 'vgw'
  vwanSlug: 'vwan'
  vwanHubSlug: 'vhub'
  webAppSlug: 'app'
}

@description('Azure container registry (ACR) name.')
output acr nameType = {
  name: replace('${baseName}${slugs.acrSlug}', separator, '')
  slug: slugs.acrSlug
}

@description('Azure Container Instance (ACI) name.')
output aci nameType = {
  name: '${baseName}${separator}${slugs.aciSlug}'
  slug: slugs.aciSlug
}

@description('Alert name.')
output alert nameType = {
  name: '${baseName}${separator}${slugs.alertSlug}'
  slug: slugs.alertSlug
}

@description('API Management (APIM) name.')
output apim nameType = {
  name: '${baseName}${separator}${slugs.apimSlug}'
  slug: slugs.apimSlug
}

@description('Action group name.')
output actionGroup nameType = {
  name: '${baseName}${separator}${slugs.actionGroupSlug}'
  slug: slugs.actionGroupSlug
}

@description('Application Gateway name.')
output appGateway nameType = {
  name: '${baseName}${separator}${slugs.appGatewaySlug}'
  slug: slugs.appGatewaySlug
}

@description('Application Gateway WAF policy name.')
output appGatewayPolicy nameType = {
  name: '${baseName}${separator}${slugs.appGatewayPolicySlug}'
  slug: slugs.appGatewayPolicySlug
}

@description('Application Insights name.')
output appInsights nameType = {
  name: '${baseName}${separator}${slugs.appInsightsSlug}'
  slug: slugs.appInsightsSlug
}

@description('App Service Plan name.')
output appServicePlan nameType = {
  name: '${baseName}${separator}${slugs.appServicePlanSlug}'
  slug: slugs.appServicePlanSlug
}

@description('Azure Kubernetes Service (AKS) name.')
output aks nameType = {
  name: '${baseName}${separator}${slugs.aksSlug}'
  slug: slugs.aksSlug
}

@description('Azure Automation Account name.')
output automationAccount nameType = {
  name: '${baseName}${separator}${slugs.autoAccountSlug}'
  slug: slugs.autoAccountSlug
}

@description('Availability Set name.')
output availabilitySet nameType = {
  name: '${baseName}${separator}${slugs.availabilitySetSlug}'
  slug: slugs.availabilitySetSlug
}

@description('Azure Bastion name.')
output bastion nameType = {
  name: '${baseName}${separator}${slugs.bastionSlug}'
  slug: slugs.bastionSlug
}

@description('Budget name.')
output budget nameType = {
  name: '${baseName}${separator}${slugs.budgetSlug}'
  slug: slugs.budgetSlug
}

@description('Azure Cosmos DB name.')
output cosmosDb nameType = {
  name: '${baseName}${separator}${slugs.cosmosDbSlug}'
  slug: slugs.cosmosDbSlug
}

@description('DDoS Protection Plan name.')
output ddosProtectionPlan nameType = {
  name: '${baseName}${separator}${slugs.ddosProtectionPlanSlug}'
  slug: slugs.ddosProtectionPlanSlug
}

@description('DNS Resolver name.')
output dnsResolver nameType = {
  name: '${baseName}${separator}${slugs.dnsResolverSlug}'
  slug: slugs.dnsResolverSlug
}

@description('ExpressRoute Circuit name.')
output expressRouteCircuit nameType = {
  name: '${baseName}${separator}${slugs.expressRouteCircuitSlug}'
  slug: slugs.expressRouteCircuitSlug
}

@description('External Load Balancer name.')
output externalLoadBalancer nameType = {
  name: '${baseName}${separator}${slugs.externalLoadBalancerSlug}'
  slug: slugs.externalLoadBalancerSlug
}

@description('Firewall name.')
output firewall nameType = {
  name: '${baseName}${separator}${slugs.firewallSlug}'
  slug: slugs.firewallSlug
}

@description('Firewall Policy name.')
output firewallPolicy nameType = {
  name: '${baseName}${separator}${slugs.firewallPolicySlug}'
  slug: slugs.firewallPolicySlug
}

@description('Front Door name.')
output frontDoor nameType = {
  name: '${baseName}${separator}${slugs.frontDoorSlug}'
  slug: slugs.frontDoorSlug
}

@description('Function App name.')
output internalLoadBalancer nameType = {
  name: '${baseName}${separator}${slugs.internalLoadBalancerSlug}'
  slug: slugs.internalLoadBalancerSlug
}

@description('Key Vault name.')
output keyVault nameType = {
  name: '${baseName}${separator}${slugs.keyVaultSlug}'
  slug: slugs.keyVaultSlug
}

@description('Load Balancer name.')
output localNetworkGateway nameType = {
  name: '${baseName}${separator}${slugs.localNetworkGatewaySlug}'
  slug: slugs.localNetworkGatewaySlug
}

@description('Log Analytics name.')
output logAnalytics nameType = {
  name: '${baseName}${separator}${slugs.logAnalyticsSlug}'
  slug: slugs.logAnalyticsSlug
}

@description('Logic App name.')
output logicApp nameType = {
  name: '${baseName}${separator}${slugs.logicAppSlug}'
  slug: slugs.logicAppSlug
}

@description('Machine Learning Workspace name.')
output mlWorkspace nameType = {
  name: '${baseName}${separator}${slugs.mlWorkspaceSlug}'
  slug: slugs.mlWorkspaceSlug
}

@description('Managed Identity name.')
output managedIdentity nameType = {
  name: '${baseName}${separator}${slugs.managedIdentitySlug}'
  slug: slugs.managedIdentitySlug
}

@description('Network Interface name.')
output networkInterface nameType = {
  name: '${baseName}${separator}${slugs.networkInterfaceSlug}'
  slug: slugs.networkInterfaceSlug
}

@description('Network Security Group name.')
output nsg nameType = {
  name: '${baseName}${separator}${slugs.nsgSlug}'
  slug: slugs.nsgSlug
}

@description('Network Security Group Flow Log name.')
output nsgFlowLog nameType = {
  name: '${baseName}${separator}${slugs.nsgFlowLogSlug}'
  slug: slugs.nsgFlowLogSlug
}

@description('Network Watcher name.')
output networkWatcher nameType = {
  name: '${baseName}${separator}${slugs.networkWatcherSlug}'
  slug: slugs.networkWatcherSlug
}

@description('Public IP Address name.')
output publicIp nameType = {
  name: '${baseName}${separator}${slugs.publicIpSlug}'
  slug: slugs.publicIpSlug
}

@description('Recovery Services Vault name.')
output recoveryServicesVault nameType = {
  name: '${baseName}${separator}${slugs.recoveryServicesVaultSlug}'
  slug: slugs.recoveryServicesVaultSlug
}

@description('Resource Group name.')
output resourceGroup nameType = {
  name: '${baseName}${separator}${slugs.resourceGroupSlug}'
  slug: slugs.resourceGroupSlug
}

@description('Route Table name.')
output routeTable nameType = {
  name: '${baseName}${separator}${slugs.routeTableSlug}'
  slug: slugs.routeTableSlug
}

@description('SQL Database name.')
output sqlDb nameType = {
  name: '${baseName}${separator}${slugs.sqlDbSlug}'
  slug: slugs.sqlDbSlug
}

@description('SQL Server name.')
output sqlServer nameType = {
  name: '${baseName}${separator}${slugs.sqlServerSlug}'
  slug: slugs.sqlServerSlug
}

@description('Storage Account name.')
output storageAccount nameType = {
  name: replace('${baseName}${slugs.storageAccountSlug}', separator, '')
  slug: slugs.storageAccountSlug
}

@description('Traffic Manager name.')
output trafficManager nameType = {
  name: '${baseName}${separator}${slugs.trafficManagerSlug}'
  slug: slugs.trafficManagerSlug
}

@description('Virtual Machine name.')
output virtualMachine nameType = {
  name: replace('${baseName}${slugs.virtualMachineSlug}', separator, '')
  slug: slugs.virtualMachineSlug
}

@description('Virtual Machine Scale Set name.')
output virtualMachineScaleSet nameType = {
  name: '${baseName}${separator}${slugs.virtualMachineScaleSetSlug}'
  slug: slugs.virtualMachineScaleSetSlug
}

@description('Virtual Network name.')
output vnet nameType = {
  name: '${baseName}${separator}${slugs.vnetSlug}'
  slug: slugs.vnetSlug
}

@description('Virtual Network Gateway name.')
output vnetGateway nameType = {
  name: '${baseName}${separator}${slugs.vnetGatewaySlug}'
  slug: slugs.vnetGatewaySlug
}

@description('Virtual WAN name.')
output vwan nameType = {
  name: '${baseName}${separator}${slugs.vwanSlug}'
  slug: slugs.vwanSlug
}

@description('Virtual WAN Hub name.')
output vwanHub nameType = {
  name: '${baseName}${separator}${slugs.vwanHubSlug}'
  slug: slugs.vwanHubSlug
}

@description('Web App name.')
output webApp nameType = {
  name: '${baseName}${separator}${slugs.webAppSlug}'
  slug: slugs.webAppSlug
}
