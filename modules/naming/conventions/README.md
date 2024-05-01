# Naming Conventions Module

This module is used to create a naming convention for resources in Azure.

## Details

This module is used to create a naming convention for resources in Azure.

It provides the flexibility to define the naming convention for resources in Azure based on the following inputs:

- Prefixes you set in the order of your choosing for the resource name.
- Suffixes you set in the order of your choosing for the resource name.
- Separator to use for the resource name, e.g. `-` or `_`. Default is `-`.
- Location of the resource.
- Specify `**location**` in the prefixes or suffixes to include the location in the resource name.
- Slug defined at the end of the resource name with resource type defined as per this [article](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

### Usage

To use this module, you need to reference it in your Bicep file and provide the required parameters to the naming module.

Example below.

```bicep
targetScope = 'subscription'

param location string = 'australiaeast'


module namingConventions '../main.bicep' = {
  name: '${uniqueString(deployment().name, location)}-naming'
  params: {
    location: location
    prefixes: [
      'msft'
      '**location**'
      'dev'

    ]
    suffixes: [
      'myapp'
    ]
  }
}

output resourceGroupName string = namingConventions.outputs.resourceGroup.name
output resourceGroupSlug string = namingConventions.outputs.resourceGroup.slug
```

The name of the resource group based on this example will be `msft-ae-dev-myapp-rg`.

The naming module will output an object with the following properties to provide you flexibility in using the naming convention within your Bicep file:

- `name`: The name of the resource based on the naming convention.
- `slug`: The resource type slug.

This will provide you with flexibility when utilising the naming convention in your Bicep file.

Example below using the outputs to name a resource.

```bicep
var appGatewayPublicIpName = '${appGatewayName}-${namingConventions.outputs.publicIp.slug}'
```

### Limitations

There is a known limitations with the current implementation of the naming convention module.

1. You cannot use the naming module where the name of the resource is required at the start of the deployment.

This typically occurs when directly creating an Azure resource in Bicep or when defining the scope on a module. This module can only be used when creating Azure resources using modules or when a module scope does not require the name of the resource to be calculated at the start of the deployment.

Examples of what you cannot do:

```bicep
resource rgDemo 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name:  namingConventions.outputs.resourceGroup.name
  location: location
  tags: {
    environment: 'dev'
  }
}

module hub_to_platform_peering 'br/ArincoModules:network/virtual-networks-peerings:1.0.2' = {
  scope: resourceGroup(subscriptionId, namingConventions.outputs.resourceGroup.name)
  name: 'hub-peer-${uniqueString(deployment().name, location)}'
  params: {
    ...
  }
}
```

It will result in the error similar to below.

`ERROR: This expression is being used in an assignment to the "name" property of the "Microsoft.Resources/resourceGroups" type, which requires a value that can be calculated at the start of the deployment. Properties of namingConventions which can be calculated at the start include "name".`

2. The slug is required to be used in the resource name and will be appended to the end of the resource name.

## Parameters

| Name                 | Type     | Required | Description                                                        |
| :------------------- | :------: | :------: | :----------------------------------------------------------------- |
| `prefixes`           | `array`  | Yes      | Prefixes to set (in order) for the resource name.                  |
| `suffixes`           | `array`  | Yes      | Suffixes to set (in order) for the resource name.                  |
| `separator`          | `string` | No       | Optional. Separator to use for the resource name, e.g. '-' or '_'. |
| `location`           | `string` | Yes      | Deployment location.                                               |
| `geoLocationCodes`   | `object` | No       | Optional. Geo-location codes for resources.                        |
| `locationIdentifier` | `string` | No       | Optional. The geo-location identifier used for all resources.      |

## Outputs

| Name                     | Type     | Description                           |
| :----------------------- | :------: | :------------------------------------ |
| `acr`                    | `object` | Azure container registry (ACR) name.  |
| `aci`                    | `object` | Azure Container Instance (ACI) name.  |
| `alert`                  | `object` | Alert name.                           |
| `apim`                   | `object` | API Management (APIM) name.           |
| `actionGroup`            | `object` | Action group name.                    |
| `appGateway`             | `object` | Application Gateway name.             |
| `appGatewayPolicy`       | `object` | Application Gateway WAF policy name.  |
| `appInsights`            | `object` | Application Insights name.            |
| `appServicePlan`         | `object` | App Service Plan name.                |
| `aks`                    | `object` | Azure Kubernetes Service (AKS) name.  |
| `automationAccount`      | `object` | Azure Automation Account name.        |
| `availabilitySet`        | `object` | Availability Set name.                |
| `bastion`                | `object` | Azure Bastion name.                   |
| `budget`                 | `object` | Budget name.                          |
| `cosmosDb`               | `object` | Azure Cosmos DB name.                 |
| `ddosProtectionPlan`     | `object` | DDoS Protection Plan name.            |
| `dnsResolver`            | `object` | DNS Resolver name.                    |
| `expressRouteCircuit`    | `object` | ExpressRoute Circuit name.            |
| `externalLoadBalancer`   | `object` | External Load Balancer name.          |
| `firewall`               | `object` | Firewall name.                        |
| `firewallPolicy`         | `object` | Firewall Policy name.                 |
| `frontDoor`              | `object` | Front Door name.                      |
| `internalLoadBalancer`   | `object` | Function App name.                    |
| `keyVault`               | `object` | Key Vault name.                       |
| `localNetworkGateway`    | `object` | Load Balancer name.                   |
| `logAnalytics`           | `object` | Log Analytics name.                   |
| `logicApp`               | `object` | Logic App name.                       |
| `mlWorkspace`            | `object` | Machine Learning Workspace name.      |
| `managedIdentity`        | `object` | Managed Identity name.                |
| `networkInterface`       | `object` | Network Interface name.               |
| `nsg`                    | `object` | Network Security Group name.          |
| `nsgFlowLog`             | `object` | Network Security Group Flow Log name. |
| `networkWatcher`         | `object` | Network Watcher name.                 |
| `publicIp`               | `object` | Public IP Address name.               |
| `recoveryServicesVault`  | `object` | Recovery Services Vault name.         |
| `resourceGroup`          | `object` | Resource Group name.                  |
| `routeTable`             | `object` | Route Table name.                     |
| `sqlDb`                  | `object` | SQL Database name.                    |
| `sqlServer`              | `object` | SQL Server name.                      |
| `storageAccount`         | `object` | Storage Account name.                 |
| `trafficManager`         | `object` | Traffic Manager name.                 |
| `virtualMachine`         | `object` | Virtual Machine name.                 |
| `virtualMachineScaleSet` | `object` | Virtual Machine Scale Set name.       |
| `vnet`                   | `object` | Virtual Network name.                 |
| `vnetGateway`            | `object` | Virtual Network Gateway name.         |
| `vwan`                   | `object` | Virtual WAN name.                     |
| `vwanHub`                | `object` | Virtual WAN Hub name.                 |
| `webApp`                 | `object` | Web App name.                         |

## Examples

Please see the [Bicep Tests](test/main.test.bicep) file for examples.