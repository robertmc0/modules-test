/*======================================================================
GLOBAL CONFIGURATION
======================================================================*/
targetScope = 'subscription'

@description('Optional. The geo-location where the resource lives.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
@minLength(1)
@maxLength(5)
param shortIdentifier string = 'arn'

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {
  environment: 'test'
}

@description('Optional. Staging resource group name.')
param stagingResourceGroupName string = '${shortIdentifier}-staging-rg-${uniqueString(deployment().name, 'resourceGroups', location)}'

// existing staging resource group cannot be used due to bug, see https://github.com/MicrosoftDocs/azure-docs/issues/103161

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource deployResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${shortIdentifier}-deploy-rg-${uniqueString(deployment().name, 'resourceGroups', location)}'
  location: location
}

module preReqs 'prereqs.main.test.bicep' = {
  scope: resourceGroup(deployResourceGroup.name)
  name: '${uniqueString(deployment().name, location)}-image-prereqs'
  params: {
    shortIdentifier: shortIdentifier
    location: location
    deployResourceGroupId: deployResourceGroup.id
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module minImageTemplate '../main.bicep' = {
  scope: resourceGroup(deployResourceGroup.name)
  name: '${uniqueString(deployment().name, location)}-min-image-tmpl'
  params: {
    imageGalleryName: '${shortIdentifier}mintstgallery${uniqueString(deployment().name, 'imageGallery', location)}'
    location: location
    tags: tags
    imageDefinitionProperties: {
      name: 'Arinco_Win11_Definition'
      publisher: 'arinco'
      offer: 'microsoftwindowsdesktop'
      sku: 'win11-22h2-avd'
    }
    hyperVGeneration: 'V2'
    imageTemplateName: '${shortIdentifier}mintstimage${uniqueString(deployment().name, 'imageTemplate', location)}'
    userIdentityId: preReqs.outputs.userIdentityId
    subnetResourceId: '${preReqs.outputs.vnetId}/subnets/default'
    sourceImage: {
      type: 'PlatformImage'
      publisher: 'microsoftwindowsdesktop'
      offer: 'windows-11'
      sku: 'win11-22h2-ent'
      version: 'latest'
    }
    customizerScriptUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/testPsScript.ps1'
    runOutputName: '${shortIdentifier}mintstimage${uniqueString(deployment().name, 'runOutputName', location)}'
  }
}

module imageTemplate '../main.bicep' = {
  scope: resourceGroup(deployResourceGroup.name)
  name: '${uniqueString(deployment().name, location)}-image-tmpl'
  params: {
    imageGalleryName: '${shortIdentifier}tstgallery${uniqueString(deployment().name, 'imageGallery', location)}'
    location: location
    tags: tags
    imageDefinitionProperties: {
      name: 'Arinco_Win11_Definition'
      publisher: 'arinco'
      offer: 'microsoftwindowsdesktop'
      sku: 'win11-22h2-avd'
    }
    imageRecommendedSettings: {
      vCPUs: {
        min: 2
        max: 32
      }
      memory: {
        min: 4
        max: 48
      }
    }
    hyperVGeneration: 'V2'
    osDiskSizeGB: 127
    imageTemplateName: '${shortIdentifier}tstimage${uniqueString(deployment().name, 'imageTemplate', location)}'
    userIdentityId: preReqs.outputs.userIdentityId
    subnetResourceId: '${preReqs.outputs.vnetId}/subnets/default'
    sourceImage: {
      type: 'PlatformImage'
      publisher: 'microsoftwindowsdesktop'
      offer: 'windows-11'
      sku: 'win11-22h2-ent'
      version: 'latest'
    }
    customizerScriptUri: 'https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/testPsScript.ps1'
    runOutputName: '${shortIdentifier}tstimage${uniqueString(deployment().name, 'runOutputName', location)}'
    stagingResourceGroupId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${stagingResourceGroupName}'
    vmSize: 'Standard_D2s_v3'
    replicationRegions: [
      'australiasoutheast'
    ]
    windowsUpdateConfiguration: [
      {
        type: 'WindowsUpdate'
        searchCriteria: 'IsInstalled=0' // finds updates that are not installed on the destination computer
        filters: [
          'exclude:$_.Title -like \'*Preview*\''
          'include:$true'
        ]
        updateLimit: 25
      }
    ]
    resourcelock: 'CanNotDelete'
  }
}
