@description('Optional. The geo-location where the resource lives.')
param location string

@description('Optional. Resource tags.')
@metadata({
  doc: 'https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-resources?tabs=bicep#arm-templates'
  example: {
    tagKey: 'string'
  }
})
param tags object = {}

@description('Azure Image Gallery name.')
@minLength(3)
@maxLength(80)
param imageGalleryName string

@description('Image definition to set for the custom image produced by the Azure Image Builder build.')
@metadata({
  name: 'Image definition name.'
  publisher: 'Publisher name.'
  offer: 'Image offer name, e.g. microsoftwindowsdesktop.'
  sku: 'Image sku name, e.g. win11-22h2-avd.'
})
param imageDefinitionProperties object

@description('Image template name.')
param imageTemplateName string

@description('Resource ID of the user-assigned managed identity used by Azure Image Builder template.')
param userIdentityId string

@description('Optional. Size of virtual machine to use for image template.')
param vmSize string = 'Standard_D4s_v5'

@description('Resource ID of the virtual machine subnet.')
param subnetResourceId string

@description('Image definition of source image to use for image template.')
@metadata({
  type: 'Image source type, allowed values PlatformImage, ManagedImage or SharedImageVersion '
  publisher: 'Publisher name.'
  offer: 'Image offer name, e.g. microsoftwindowsdesktop.'
  sku: 'Image sku name, e.g. win11-22h2-ent.'
  version: 'Image version, e.g. latest'
})
param sourceImage object

@description('Optional. Resource ID of the staging resource group that host resources used during image build.')
param stagingResourceGroupId string = ''

@description('Image name to create and distribute using Azure Image Builder.')
param runOutputName string

@description('Optional. Azure regions where you would like to replicate the custom image after it is created.')
param replicationRegions array = []

@description('Storage Blob URL to the PowerShell script containing the image customisation configuration.')
param customizerScriptUri string

@description('Optional. Windows update configuration for image template.')
@metadata({
  doc: 'https://learn.microsoft.com/en-us/azure/templates/microsoft.virtualmachineimages/imagetemplates?pivots=deployment-language-bicep#imagetemplatewindowsupdatecustomizer'
  example: {
    type: 'WindowsUpdate'
    searchCriteria: 'Criteria to search updates.'
    filters: [
      'Array of filters to select updates to apply.'
    ]
    updateLimit: 'Maximum number of updates to apply at a time'
  }
})
param windowsUpdateConfiguration array = [
  {
    type: 'WindowsUpdate'
    searchCriteria: 'IsInstalled=0' // finds updates that are not installed on the destination computer
    filters: [
      'exclude:$_.Title -like \'*Preview*\''
      'include:$true'
    ]
    updateLimit: 40
  }
]

@description('Optional. Recommended compute and memory settings for image.')
@metadata({
  vCPUs: {
    min: 'integer containing recommended minimum CPU configuration.'
    max: 'integer containing recommended maximum CPU configuration.'
  }
  memory: {
    min: 'integer containing recommended minimum memory configuration.'
    max: 'integer containing recommended maximum memory configuration.'
  }
})
param imageRecommendedSettings object = {
  vCPUs: {
    min: 2
    max: 8
  }
  memory: {
    min: 16
    max: 48
  }
}

@description('Optional. OS disk size in gigabytes.')
param osDiskSizeGB int = 127

@description('Optional. Build timeout in minutes.')
param buildTimeoutInMinutes int = 120

@allowed([
  'CanNotDelete'
  'NotSpecified'
  'ReadOnly'
])
@description('Optional. Specify the type of resource lock.')
param resourcelock string = 'NotSpecified'

var imageGalleryLockName = toLower('${imageGallery.name}-${resourcelock}-lck')

var imageDefinitionLockName = toLower('${imageDefinition.name}-${resourcelock}-lck')

var imageTemplateLockName = toLower('${imageTemplate.name}-${resourcelock}-lck')

var defaultCustomiserSettings = [
  {
    type: 'PowerShell'
    name: 'ConfigureVM'
    runElevated: true
    runAsSystem: true
    scriptUri: customizerScriptUri
  }
  {
    type: 'WindowsRestart'
    restartCommand: 'shutdown /r /f /t 0'
    restartCheckCommand: 'echo Azure-Image-Builder-Restarted-the-VM > c:\\users\\packer\\azureImageBuilderRestart.txt'
    restartTimeout: '5m'
  }
]

var customiserSettings = union(defaultCustomiserSettings, windowsUpdateConfiguration)

resource imageGallery 'Microsoft.Compute/galleries@2022-03-03' = {
  name: imageGalleryName
  location: location
  tags: tags
  properties: {}
}

resource imageGalleryLock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: imageGallery
  name: imageGalleryLockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource imageDefinition 'Microsoft.Compute/galleries/images@2022-03-03' = {
  parent: imageGallery
  name: imageDefinitionProperties.name
  location: location
  properties: {
    osType: 'Windows'
    osState: 'Generalized'
    identifier: {
      publisher: imageDefinitionProperties.publisher
      offer: imageDefinitionProperties.offer
      sku: imageDefinitionProperties.sku
    }
    recommended: imageRecommendedSettings
    hyperVGeneration: 'V2'
  }
}

resource imageDefinitionLock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: imageDefinition
  name: imageDefinitionLockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

resource imageTemplate 'Microsoft.VirtualMachineImages/imageTemplates@2022-02-14' = {
  name: imageTemplateName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userIdentityId}': {}
    }
  }
  properties: {
    buildTimeoutInMinutes: buildTimeoutInMinutes
    vmProfile: {
      vmSize: vmSize
      osDiskSizeGB: osDiskSizeGB
      vnetConfig: {
        subnetId: subnetResourceId
      }
      userAssignedIdentities: [
        userIdentityId
      ]
    }
    source: sourceImage
    stagingResourceGroup: stagingResourceGroupId
    customize: customiserSettings
    distribute: [
      {
        type: 'SharedImage'
        galleryImageId: imageDefinition.id
        runOutputName: runOutputName
        replicationRegions: replicationRegions
      }
    ]
  }
}

resource imageTemplateLock 'Microsoft.Authorization/locks@2017-04-01' = if (resourcelock != 'NotSpecified') {
  scope: imageTemplate
  name: imageTemplateLockName
  properties: {
    level: resourcelock
    notes: (resourcelock == 'CanNotDelete') ? 'Cannot delete resource or child resources.' : 'Cannot modify the resource or child resources.'
  }
}

@description('The name of the deployed image template.')
output name string = imageTemplate.name

@description('The resource ID of the deployed image template.')
output resourceId string = imageTemplate.id

@description('Size of virtual machine used for the image template.')
output vmSize string = 'Standard_D4s_v5'
