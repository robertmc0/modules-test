
metadata name = 'Container App'
metadata description = 'This module deploys Microsoft.App/containerApps'
metadata owner = 'Arinco'

@description('The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Resource ID of the container app managed environment.')
param containerAppsEnvironmentId string

@description('Name of the container app.')
param containerName string

@description('Optional. Container environment variables.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#environmentvar'
  example: {
    name: 'string'
    secretRef: 'string'
    value: 'string'
  }
})
param env array = []

@description('Optional. The type of identity for the resource.')
@allowed([ 
    'None'
    'SystemAssigned'
    'UserAssigned' 
])
param identityType string = 'None'

@description('Container image to deploy.')
param imageName string

@description('Optional. Specifies if Ingress is enabled for the container app.')
param ingressEnabled bool = true

@description('Optional. Active revisions for container apps.')
@allowed([
    'Single'
    'Multiple'
    'Labels'
])
param activeRevisionsMode string = 'Single'

@description('Optional. Dapr configuration for the Container App.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#dapr'
  example: {
    appId: 'string'
    appPort: 'int'
    appProtocol: 'string' //http or grpc
    enableApiLogging: 'bool'
    enabled: 'bool'
    httpMaxRequestSize: 'int'
    httpReadBufferSize: 'int'
    logLevel: 'string' // Allowed values are 'debug','error','info','warn'
  }
})
param dapr object = {}

@description('Optional. Ingress configurations for the Container App.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#ingress'
  example: {
    transport: 'string' //auto, http, http2, tcp
    targetPort: 'int'
    targetPortHttpScheme: 'string' //http or https
    external: 'bool'
    corsPolicy: {
     allowedOrigins: 'array'
    }
  }
  })
param ingress object = {}

@description('Optional. Scaling properties for the Container App.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#scale'
  example: {
    pollingInterval: 'int' //defaults to 30 seconds
    cooldownPeriod: 'int' //defaults to 300 seconds
    maxReplicas: 'int' //defaults to 10
    minReplicas: 'int'
    rules:[]
  }
  })
param scale object = {}

@description('Optional. Collection of secrets used by a Container app.')
param secrets array = []

@description('Optional. List of container app services bound to the app.')
@metadata({
  clientType: 'string'
  name: 'string'
  serviceId: 'string'
  customizedKeys: 'object'
})
param serviceBinds array = []

@description('Optional. The ID(s) to assign to the resource.')
@metadata({
  example: {
    '/subscriptions/<subscription>/resourceGroups/<rgp>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/dev-umi': {}
  }
})
param userAssignedIdentities object = {}

@description('Optional. Collection of private container registry credentials for containers used by the Container app.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#servicebind'
  example: {
    passwordSecretRef: 'string'
    server: 'string'
    identity: 'string'
    username: 'string'
   }
})
param registries array = []

@description('Optional. Service type for container apps, required only for dev container apps.')
param serviceType string = ''

@description('Optional. Container resource requirements.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.app/containerapps?pivots=deployment-language-bicep#containerresources'
  example: {
  cpu: 'int'
  gpu: 'int'
  memory: 'string'
  }
})
param containerResources object = {}

var identity = identityType != 'None' ? {
  type: identityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? userAssignedIdentities : null
} : null

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: containerName
  location: location
  tags: tags
  identity: identity
  properties: {
    managedEnvironmentId: containerAppsEnvironmentId
    configuration: {
      activeRevisionsMode: activeRevisionsMode
      ingress: ingress
      dapr: dapr
      secrets: secrets
      service: {
       type: serviceType
      }
      registries: registries
    }
    template: {
      serviceBinds: !empty(serviceBinds) ? serviceBinds : null
      containers: [
        {
          image: imageName
          name: containerName
          env: env
          resources: containerResources
        }
      ]
      scale: scale
    }
  }
}

@description('Name of the image deployed to the container app.')
output name string = containerApp.name

@description('Resource Id of the container app.')
output resourceId string = containerApp.id

@description('Url of the deployed application as container app.')
output containerAppFQDN string = ingressEnabled ? 'https://${containerApp.properties.configuration.ingress.fqdn}' : ''
