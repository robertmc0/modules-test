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

var acrSlug = 'cr'
var aciSlug = 'ci'
var alertSlug = 'alert'
var apimSlug = 'apim'
var actionGroupSlug = 'ag'
var appGatewaySlug = 'agw'
var appGatewayPolicySlug = 'waf'
var appInsightsSlug = 'appi'
var appServicePlanSlug = 'asp'
var aksSlug = 'aks'
var autoAccountSlug = 'aa'
var availabilitySetSlug = 'avail'
var bastionSlug = 'bas'
var budgetSlug = 'bgt'
var cosmosDbSlug = 'cosmos'
var ddosProtectionPlanSlug = 'ddos'
var dnsResolverSlug = 'dnspr'
var expressRouteCircuitSlug = 'erc'
var externalLoadBalancerSlug = 'lbe'
var firewallSlug = 'afw'
var firewallPolicySlug = 'afwp'
var frontDoorSlug = 'afd'
var internalLoadBalancerSlug = 'lbi'
var keyVaultSlug = 'kv'
var localNetworkGatewaySlug = 'lgw'
var logAnalyticsSlug = 'log'
var logicAppSlug = 'logic'
var mlWorkspaceSlug = 'mlw'
var managedIdentitySlug = 'id'
var networkInterfaceSlug = 'nic'
var nsgSlug = 'nsg'
var nsgFlowLogSlug = 'flow'
var networkWatcherSlug = 'nw'
var publicIpSlug = 'pip'
var recoveryServicesVaultSlug = 'rsv'
var resourceGroupSlug = 'rg'
var routeTableSlug = 'rt'
var sqlDbSlug = 'sqldb'
var sqlServerSlug = 'sql'
var storageAccountSlug = 'st'
var trafficManagerSlug = 'traf'
var virtualMachineSlug = 'vm'
var virtualMachineScaleSetSlug = 'vmss'
var vnetSlug = 'vnet'
var vnetGatewaySlug = 'vgw'
var vwanSlug = 'vwan'
var vwanHubSlug = 'vhub'
var webAppSlug = 'app'

@description('Azure container registry (ACR) name.')
output acr nameType = {
  name: replace('${baseName}${acrSlug}', separator, '')
  slug: acrSlug
}

@description('Azure Container Instance (ACI) name.')
output aci nameType = {
  name: '${baseName}${separator}${aciSlug}'
  slug: aciSlug
}

@description('Alert name.')
output alert nameType = {
  name: '${baseName}${separator}${alertSlug}'
  slug: alertSlug
}

@description('API Management (APIM) name.')
output apim nameType = {
  name: '${baseName}${separator}${apimSlug}'
  slug: apimSlug
}

@description('Action group name.')
output actionGroup nameType = {
  name: '${baseName}${separator}${actionGroupSlug}'
  slug: actionGroupSlug
}

@description('Application Gateway name.')
output appGateway nameType = {
  name: '${baseName}${separator}${appGatewaySlug}'
  slug: appGatewaySlug
}

@description('Application Gateway WAF policy name.')
output appGatewayPolicy nameType = {
  name: '${baseName}${separator}${appGatewayPolicySlug}'
  slug: appGatewayPolicySlug
}

@description('Application Insights name.')
output appInsights nameType = {
  name: '${baseName}${separator}${appInsightsSlug}'
  slug: appInsightsSlug
}

@description('App Service Plan name.')
output appServicePlan nameType = {
  name: '${baseName}${separator}${appServicePlanSlug}'
  slug: appServicePlanSlug
}

@description('Azure Kubernetes Service (AKS) name.')
output aks nameType = {
  name: '${baseName}${separator}${aksSlug}'
  slug: aksSlug
}

@description('Azure Automation Account name.')
output automationAccount nameType = {
  name: '${baseName}${separator}${autoAccountSlug}'
  slug: autoAccountSlug
}

@description('Availability Set name.')
output availabilitySet nameType = {
  name: '${baseName}${separator}${availabilitySetSlug}'
  slug: availabilitySetSlug
}

@description('Azure Bastion name.')
output bastion nameType = {
  name: '${baseName}${separator}${bastionSlug}'
  slug: bastionSlug
}

@description('Budget name.')
output budget nameType = {
  name: '${replace(trim(subscription().displayName), ' ', '')}-${budgetSlug}'
  slug: budgetSlug
}

@description('Azure Cosmos DB name.')
output cosmosDb nameType = {
  name: '${baseName}${separator}${cosmosDbSlug}'
  slug: cosmosDbSlug
}

@description('DDoS Protection Plan name.')
output ddosProtectionPlan nameType = {
  name: '${baseName}${separator}${ddosProtectionPlanSlug}'
  slug: ddosProtectionPlanSlug
}

@description('DNS Resolver name.')
output dnsResolver nameType = {
  name: '${baseName}${separator}${dnsResolverSlug}'
  slug: dnsResolverSlug
}

@description('ExpressRoute Circuit name.')
output expressRouteCircuit nameType = {
  name: '${baseName}${separator}${expressRouteCircuitSlug}'
  slug: expressRouteCircuitSlug
}

@description('External Load Balancer name.')
output externalLoadBalancer nameType = {
  name: '${baseName}${separator}${externalLoadBalancerSlug}'
  slug: externalLoadBalancerSlug
}

@description('Firewall name.')
output firewall nameType = {
  name: '${baseName}${separator}${firewallSlug}'
  slug: firewallSlug
}

@description('Firewall Policy name.')
output firewallPolicy nameType = {
  name: '${baseName}${separator}${firewallPolicySlug}'
  slug: firewallPolicySlug
}

@description('Front Door name.')
output frontDoor nameType = {
  name: '${baseName}${separator}${frontDoorSlug}'
  slug: frontDoorSlug
}

@description('Function App name.')
output internalLoadBalancer nameType = {
  name: '${baseName}${separator}${internalLoadBalancerSlug}'
  slug: internalLoadBalancerSlug
}

@description('Key Vault name.')
output keyVault nameType = {
  name: '${baseName}${separator}${keyVaultSlug}'
  slug: keyVaultSlug
}

@description('Load Balancer name.')
output localNetworkGateway nameType = {
  name: '${baseName}${separator}${localNetworkGatewaySlug}'
  slug: localNetworkGatewaySlug
}

@description('Log Analytics name.')
output logAnalytics nameType = {
  name: '${baseName}${separator}${logAnalyticsSlug}'
  slug: logAnalyticsSlug
}

@description('Logic App name.')
output logicApp nameType = {
  name: '${baseName}${separator}${logicAppSlug}'
  slug: logicAppSlug
}

@description('Machine Learning Workspace name.')
output mlWorkspace nameType = {
  name: '${baseName}${separator}${mlWorkspaceSlug}'
  slug: mlWorkspaceSlug
}

@description('Managed Identity name.')
output managedIdentity nameType = {
  name: '${baseName}${separator}${managedIdentitySlug}'
  slug: managedIdentitySlug
}

@description('Network Interface name.')
output networkInterface nameType = {
  name: '${baseName}${separator}${networkInterfaceSlug}'
  slug: networkInterfaceSlug
}

@description('Network Security Group name.')
output nsg nameType = {
  name: '${baseName}${separator}${nsgSlug}'
  slug: nsgSlug
}

@description('Network Security Group Flow Log name.')
output nsgFlowLog nameType = {
  name: '${baseName}${separator}${nsgFlowLogSlug}'
  slug: nsgFlowLogSlug
}

@description('Network Watcher name.')
output networkWatcher nameType = {
  name: '${baseName}${separator}${networkWatcherSlug}'
  slug: networkWatcherSlug
}

@description('Public IP Address name.')
output publicIp nameType = {
  name: '${baseName}${separator}${publicIpSlug}'
  slug: publicIpSlug
}

@description('Recovery Services Vault name.')
output recoveryServicesVault nameType = {
  name: '${baseName}${separator}${recoveryServicesVaultSlug}'
  slug: recoveryServicesVaultSlug
}

@description('Resource Group name.')
output resourceGroup nameType = {
  name: '${baseName}${separator}${resourceGroupSlug}'
  slug: resourceGroupSlug
}

@description('Route Table name.')
output routeTable nameType = {
  name: '${baseName}${separator}${routeTableSlug}'
  slug: routeTableSlug
}

@description('SQL Database name.')
output sqlDb nameType = {
  name: '${baseName}${separator}${sqlDbSlug}'
  slug: sqlDbSlug
}

@description('SQL Server name.')
output sqlServer nameType = {
  name: '${baseName}${separator}${sqlServerSlug}'
  slug: sqlServerSlug
}

@description('Storage Account name.')
output storageAccount nameType = {
  name: replace('${baseName}${storageAccountSlug}', separator, '')
  slug: storageAccountSlug
}

@description('Traffic Manager name.')
output trafficManager nameType = {
  name: '${baseName}${separator}${trafficManagerSlug}'
  slug: trafficManagerSlug
}

@description('Virtual Machine name.')
output virtualMachine nameType = {
  name: replace('${baseName}${virtualMachineSlug}', separator, '')
  slug: virtualMachineSlug
}

@description('Virtual Machine Scale Set name.')
output virtualMachineScaleSet nameType = {
  name: '${baseName}${separator}${virtualMachineScaleSetSlug}'
  slug: virtualMachineScaleSetSlug
}

@description('Virtual Network name.')
output vnet nameType = {
  name: '${baseName}${separator}${vnetSlug}'
  slug: vnetSlug
}

@description('Virtual Network Gateway name.')
output vnetGateway nameType = {
  name: '${baseName}${separator}${vnetGatewaySlug}'
  slug: vnetGatewaySlug
}

@description('Virtual WAN name.')
output vwan nameType = {
  name: '${baseName}${separator}${vwanSlug}'
  slug: vwanSlug
}

@description('Virtual WAN Hub name.')
output vwanHub nameType = {
  name: '${baseName}${separator}${vwanHubSlug}'
  slug: vwanHubSlug
}

@description('Web App name.')
output webApp nameType = {
  name: '${baseName}${separator}${webAppSlug}'
  slug: webAppSlug
}
