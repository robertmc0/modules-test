@description('The resource name.')
param name string

@description('Action Group Resource IDs.')
param actionGroupIds array

@description('Optional. A list of resource IDs that will be used as prefixes. The alert will only apply to Activity Log events with resource IDs that fall under one of these prefixes.')
param scopes array = [
  subscription().id
]

@description('Optional. Azure Services to scope to Service Health alert. Leave empty to add all services.')
@allowed([
  'API Management'
  'Action Groups'
  'Activity Logs & Alerts'
  'Advisor'
  'Alerts'
  'Alerts & Metrics'
  'App Service'
  'App Service (Linux)'
  'App Service (Linux) \\ Web App for Containers'
  'App Service (Linux) \\ Web Apps'
  'App Service \\ Web Apps'
  'Application Gateway'
  'Application Insights'
  'AutoScale'
  'Automation'
  'Azure Active Directory'
  'Azure Active Directory B2C'
  'Azure Active Directory Domain Services'
  'Azure Active Directory \\ Enterprise State Roaming'
  'Azure Analysis Services'
  'Azure API for FHIR'
  'Azure Applied AI Services'
  'Azure Arc enabled Kubernetes'
  'Azure Arc enabled data services'
  'Azure Arc enabled servers'
  'Azure Bastion'
  'Azure Blockchain Service'
  'Azure Blueprints'
  'Azure Bot Service'
  'Azure Chaos Studio'
  'Azure Communication Services'
  'Azure Container Apps'
  'Azure Container Registry'
  'Azure Container Service'
  'Azure Cosmos DB'
  'Azure DDoS Protection'
  'Azure DNS'
  'Azure Data Explorer'
  'Azure Data Lake Storage Gen1'
  'Azure Data Lake Storage Gen2'
  'Azure Data Share'
  'Azure Database for MySQL'
  'Azure Database for MySQL flexible servers'
  'Azure Database for PostgreSQL'
  'Azure Database for PostgreSQL flexible servers'
  'Azure Database Migration Service'
  'Azure Databricks'
  'Azure Dedicated Host'
  'Azure DevOps'
  'Azure DevOps \\ Artifacts'
  'Azure DevOps \\ Boards'
  'Azure DevOps \\ Pipelines'
  'Azure DevOps \\ Repos'
  'Azure DevOps \\ Test Plans'
  'Azure DevTest Labs'
  'Azure Digital Twins'
  'Azure FarmBeats'
  'Azure Firewall'
  'Azure Firewall Manager'
  'Azure Fluid Relay'
  'Azure Frontdoor'
  'Azure Health Data Services'
  'Azure HPC Cache'
  'Azure Information Protection'
  'Azure Immersive Reader'
  'Azure IoT Hub'
  'Azure Key Vault Managed HSM'
  'Azure Kubernetes Service (AKS)'
  'Azure Kubernetes Service On Azure Stack HCI'
  'Azure Lab Services'
  'Azure Load Testing'
  'Azure Managed Applications'
  'Azure Managed Instance for Apache Cassandra'
  'Azure Maps'
  'Azure Migrate'
  'Azure Monitor'
  'Azure Netapp Files'
  'Azure Network Function Manager - Device'
  'Azure Network Function Manager - Network Function'
  'Azure Open Datasets'
  'Azure Orbital'
  'Azure Peering Service'
  'Azure Policy'
  'Azure Private Link'
  'Azure Purview'
  'Azure Red Hat OpenShift'
  'Azure Reservations'
  'Azure Resource Manager'
  'Azure Resource Mover'
  'Azure Search'
  'Azure Sentinel'
  'Azure Metrics Advisor'
  'Azure SignalR Service'
  'Azure Spatial Anchors'
  'Azure Sphere'
  'Azure Spring Cloud'
  'Azure SQL Migration extension for Azure Data Studio powered by Azure Database Migration Service'
  'Azure Stack'
  'Azure Stack Edge'
  'Azure Stack HCI'
  'Azure Static Web Apps'
  'Azure Synapse Analytics'
  'Azure Video Analyzer'
  'Azure Video Analyzer For Media'
  'Azure VMware Solution'
  'Azure VMware Solution by CloudSimple'
  'Azure Web PubSub'
  'Recovery Services vault'
  'Batch'
  'BareMetal Infrastructure'
  'CDN'
  'Change Analysis'
  'Cloud Services'
  'Cloud Shell'
  'Cognitive Services \\ Anomaly Detector'
  'Cognitive Services \\ Azure Metrics Advisor'
  'Cognitive Services \\ Bing Autosuggest API'
  'Cognitive Services \\ Bing Search API'
  'Cognitive Services \\ Bing Speech API'
  'Cognitive Services \\ Bing Spell Check API'
  'Cognitive Services \\ Bing Video Search API'
  'Cognitive Services \\ Bing Visual Search API'
  'Cognitive Services \\ Bing Web Search API'
  'Cognitive Services \\ Computer Vision API'
  'Cognitive Services \\ Content Moderator API'
  'Cognitive Services \\ Custom Vision API'
  'Cognitive Services \\ Face API'
  'Cognitive Services \\ Form Recognizer API'
  'Cognitive Services \\ Azure Form Recognizer'
  'Cognitive Services \\ Image Search API'
  'Cognitive Services \\ Language Understanding (LUIS)'
  'Cognitive Services \\ News Search API'
  'Cognitive Services \\ Personalizer API'
  'Cognitive Services \\ QnA Maker API'
  'Cognitive Services \\ Speech Services API'
  'Cognitive Services \\ Speaker Recognition API'
  'Cognitive Services \\ Text Analytics API'
  'Cognitive Services \\ Translator Speech API'
  'Cognitive Services \\ Translator Text API'
  'Container Instances'
  'Container Registry'
  'Cost Management'
  'Data Catalog'
  'Data Factory'
  'Data Factory V2'
  'Data Factory V2 \\ SSIS Integration Runtime'
  'Data Factory \\ Azure Integration Runtime'
  'Data Lake Analytics'
  'Diagnostic Logs'
  'Event Grid'
  'Event Hubs'
  'ExpressRoute'
  'ExpressRoute \\ ExpressRoute Circuits'
  'ExpressRoute \\ ExpressRoute Gateways'
  'Functions'
  'HDInsight'
  'Health Bot'
  'HockeyApp'
  'Internet Analyzer'
  'IoT Central'
  'IoT Hub \\ IoT Hub Device Provisioning Service'
  'Key Vault'
  'Load Balancer'
  'Log Analytics'
  'Logic Apps'
  'Machine Learning Services'
  'Machine Learning Services \\ Machine Learning Experimentation Service'
  'Machine Learning Services \\ Machine Learning Model Management'
  'Machine Learning Studio'
  'MariaDB'
  'Marketplace'
  'Media Services \\ Encoding'
  'Media Services \\ Streaming'
  'Microsoft Azure Attestation'
  'Microsoft Azure portal'
  'Microsoft Azure portal \\ Marketplace'
  'Microsoft Defender for Cloud'
  'Microsoft Defender for IoT'
  'Microsoft Genomics'
  'Mobile Engagement'
  'Multi-Factor Authentication'
  'Network Infrastructure'
  'Network Watcher'
  'Notification Hubs'
  'Power BI Embedded'
  'Redis Cache'
  'Remote Rendering'
  'SAP HANA on Azure Large Instances'
  'SQL Data Warehouse'
  'SQL Database'
  'SQL Managed Instance'
  'SQL Server on Azure Virtual Machines'
  'SQL Server Stretch Database'
  'Scheduler'
  'Security Center'
  'Service Bus'
  'Service Fabric'
  'Site Recovery'
  'StorSimple'
  'Storage'
  'Stream Analytics'
  'Subscription Management'
  'Time Series Insights'
  'Traffic Manager'
  'VPN Gateway'
  'VPN Gateway \\ Virtual WAN'
  'Virtual Machine Scale Sets'
  'Virtual Machines'
  'Virtual Network'
  'Windows 10 IoT Core Services'
  'Windows Virtual Desktop'
  'Azure Automanage'
  'Microsoft Graph'
  'Azure confidential ledger'
  'Azure Managed Grafana'
])
param serviceNames array = []

@description('Optional. Incident Types to scope to Service Health alert. Leave empty to add all incident types.')
@allowed([
  'Incident'
  'Maintenance'
  'Informational'
  'ActionRequired'
  'Security'
])
param incidentTypes array = []

@description('Optional. Regions to scope to Service Health alert. Leave empty to add all regions.')
@allowed([
  'Global'
  'Australia Central'
  'Australia Central 2'
  'Australia East'
  'Australia Southeast'
  'Southeast Asia'
  'Japan West'
  'Japan East'
  'Korea Central'
  'Korea South'
  'South India'
  'Central India'
  'West India'
  'Canada Central'
  'Canada East'
  'Central US'
  'East US'
  'East US 2'
  'West US'
  'North Central US'
  'South Central US'
  'West Central US'
  'West US 2'
  'West US 3'
  'UAE Central'
  'UAE North'
  'South Africa North'
  'South Africa West'
  'France Central'
  'France South'
  'UK South'
  'UK West'
  'North Europe'
  'West Europe'
  'Switzerland North'
  'Switzerland West'
  'Germany North'
  'Germany West Central'
  'Norway West'
  'Norway East'
  'Brazil South'
  'Brazil Southeast'
  'Sweden Central'
  'Qatar Central'
])
param regions array = []

var baseCondition = [ {
    field: 'category'
    equals: 'ServiceHealth'
  } ]

var regionFilter = empty(regions) ? [] : [ {
    field: 'properties.impactedServices[*].ImpactedRegions[*].RegionName'
    containsAny: regions
  } ]

var serviceFilter = empty(serviceNames) ? [] : [ {
    field: 'properties.impactedServices[*].ServiceName'
    containsAny: serviceNames
  } ]

var incidentFilterArray = [for type in incidentTypes: {
  field: 'properties.incidentType'
  equals: type
}]

var incidentFilter = [ {
    anyOf: incidentFilterArray
  } ]

var completeBaseCondition = union(baseCondition, serviceFilter, regionFilter)
var fullCondition = empty(incidentTypes) ? completeBaseCondition : union(completeBaseCondition, incidentFilter)

resource serviceHealthAlert 'Microsoft.Insights/activityLogAlerts@2020-10-01' = {
  name: name
  location: 'Global'
  properties: {
    enabled: true
    scopes: scopes
    condition: {
      allOf: fullCondition
    }
    actions: {
      actionGroups: [for actionGroup in actionGroupIds: {
        actionGroupId: actionGroup
      }]
    }
  }
}

@description('The name of the deployed service health alert.')
output name string = serviceHealthAlert.name

@description('The resource ID of the deployed service health alert.')
output resourceId string = serviceHealthAlert.id
