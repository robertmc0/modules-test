/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/

targetScope = 'resourceGroup'

@description('The geo-location where the resource lives.')
param location string = resourceGroup().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

/*======================================================================
TEST EXECUTION
======================================================================*/
resource containerAppsEnvironment 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: '${uniqueString(deployment().name, location)}-capp-me'
  location: location
}

module minContainerApp '../main.bicep' = {
    name: '${uniqueString(deployment().name, location)}-min-capp'
    params: {
      location: location
      containerAppsEnvironmentId: containerAppsEnvironment.id
      containerName: '${shortIdentifier}${location}ct'
      imageName:  'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest' 
      containerResources: {
        cpu: '0.5'
        memory: '1.0Gi'
      }
    }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: '${uniqueString(deployment().name, location)}acr'
  location: location
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

module maxContainerApp '../main.bicep' = {
    name: '${uniqueString(deployment().name, location)}-max-capp'
    params: {
      location: location
      identityType: 'SystemAssigned'
      containerAppsEnvironmentId: containerAppsEnvironment.id
      containerName: '${shortIdentifier}${location}ct'
      imageName:  'mcr.microsoft.com/azuredocs/containerapps-helloworld:latest' 
      activeRevisionsMode: 'Single'
      ingressEnabled: true
      ingress: {
          targetPort: 80
          external: true
      }
      registries: [
        {
          server: containerRegistry.name
          username: containerRegistry.properties.loginServer
          passwordSecretRef: 'container-registry-password'
        }
      ]
      secrets: [
        {
          name: 'container-registry-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      containerResources: {
        cpu: '0.5'
        memory: '1.0Gi'
      }
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
}