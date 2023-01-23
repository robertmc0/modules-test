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

/*======================================================================
TEST PREREQUISITES
======================================================================*/
resource deployResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${shortIdentifier}-deploy2-rg-${uniqueString(deployment().name, 'resourceGroups', location)}'
  location: location
}

resource stagingResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${shortIdentifier}-staging2-rg-${uniqueString(deployment().name, 'resourceGroups', location)}'
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

module stagingRoleAssignment 'resource-group-role-assignment.bicep' = {
  scope: resourceGroup(stagingResourceGroup.name)
  name: '${uniqueString(deployment().name, location)}-stage-roleasgmt'
  params: {
    roleAssignmentName: guid(shortIdentifier, preReqs.outputs.userIdentityId, 'b24988ac-6180-42a0-ab88-20f7382dd24c')
    principalId: preReqs.outputs.userIdentityPrincipalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c') // Contributor role
  }
}

/*======================================================================
TEST EXECUTION
======================================================================*/
module minImageTemplate '../main.bicep' = {
  scope: resourceGroup(deployResourceGroup.name)
  dependsOn: [
    stagingRoleAssignment
  ]
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
  dependsOn: [
    stagingRoleAssignment
  ]
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
    stagingResourceGroupId: stagingResourceGroup.id
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
