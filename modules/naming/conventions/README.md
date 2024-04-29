# Naming Conventions Module

This module is used to create a naming convention for resources in Azure

## Details

This module is used to create a naming convention for resources in Azure.
The naming convention is based on the following format:

- Prefix with company identifier.
- Geo location code (based on Azure regions, e.g. ase, ae, etc.).
- Optionally include environment for workload deployment differentiation (e.g app services, SQL servers, etc.).
- Include a description of the application or service name.
- Suffix with resource type as per this [article](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

The naming convention is as follows:

```
<companyPrefix>-<locationIdentifier>-<environment>-<descriptor>-<resourceType>
```

### Usage

To use this module, you need to reference it in your Bicep file and provide the required parameters to the naming module.

You also need to replace the `<descriptor>` placeholder with the actual description of the resource you are creating.

Example below.

```bicep
targetScope = 'subscription'

param location string = 'australiaeast'

module namingConventions 'modules/naming-conventions/naming-conventions.bicep' = {
  name: 'naming_conventions'
  params: {
    companyPrefix: 'msft'
    location: location
    environment: 'dev'
  }
}

module rgDemo 'modules/resource-group/resource-group.bicep' = {
  name: 'resource-group-${uniqueString(deployment().name, location)}'
  params: {
    name: replace(namingConventions.outputs.resourceGroup.name, '<descriptor>', 'demo')
    location: location
    tags: {
      environment: 'dev'
    }
  }
}

output resourceGroupName string = rgDemo.outputs.name
```

The name of the resource group based on this example will be `msft-ae-dev-demo-rg`.

The naming module will output an object with the following properties to provide you flexibility in using the naming convention within your Bicep file:

- `name`: The name of the resource based on the naming convention.
- `prefix`: The company prefix.
- `location`: The geo location code.
- `environment`: The environment (if specified).
- `descriptor`: The description of the resource.
- `suffix`: The resource type suffix.

`NOTE:` Most resources have all these properties but some will only have a subset as the naming convention is not applicable to all resources, for example, network watcher, budgets, etc.

This will provide you with flexibility when utilising the naming convention in your Bicep file.

Example below using the outputs to name a resource.

```bicep
var appGatewayPublicIpName = '${appGatewayName}-${namingConventions.outputs.publicIp.suffix}'
```

### Limitations

There is a known limitation with the current implementation of the naming convention module.

You cannot use the naming module where the name of the resource is required at the start of the deployment.

This typically occurs when directly creating an Azure resource in Bicep or when defining the scope on a module. This module can only be used when creating Azure resources using modules or when a module scope does not require the name of the resource to be calculated at the start of the deployment.

Examples of what you cannot do:

```bicep
resource rgDemo 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name:  replace(namingConventions.outputs.resourceGroupName, '<descriptor>', 'demo')
  location: location
  tags: {
    environment: 'dev'
  }
}

module hub_to_platform_peering 'br/ArincoModules:network/virtual-networks-peerings:1.0.2' = {
  scope: resourceGroup(subscriptionId, namingConventions.outputs.resourceGroupName)
  name: 'hub-peer-${uniqueString(deployment().name, location)}'
  params: {
    ...
  }
}
```

It will result in the error similar to below.

`ERROR: This expression is being used in an assignment to the "name" property of the "Microsoft.Resources/resourceGroups" type, which requires a value that can be calculated at the start of the deployment. Properties of namingConventions which can be calculated at the start include "name".`

## Parameters

| Name                 | Type     | Required | Description                                                     |
| :------------------- | :------: | :------: | :-------------------------------------------------------------- |
| `companyPrefix`      | `string` | Yes      | Company prefix.                                                 |
| `location`           | `string` | Yes      | Deployment location.                                            |
| `geoLocationCodes`   | `object` | No       | Optional. Geo-location codes for resources.                     |
| `environment`        | `string` | No       | Optional. The name of the environment.                          |
| `descriptor`         | `string` | No       | Optional. Short description of the application or service name. |
| `locationIdentifier` | `string` | No       | Optional. The geo-location identifier used for all resources.   |

## Outputs

| Name                     | Type     | Description                           |
| :----------------------- | :------: | :------------------------------------ |
| `acr`                    | `object` | Azure container registry (ACR) name.  |
| `aci`                    | `object` | Azure Container Instance (ACI) name.  |
| `alert`                  | `object` | Azure Kubernetes Service (AKS) name.  |
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