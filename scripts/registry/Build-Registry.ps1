#requires -version 6.0
<#
  .SYNOPSIS
    Script used to build and copy bicep modules from a container registry to another registry in a different tenant. The script uses AD Authentication to access
    the source and target registry.

  .DESCRIPTION
    This script does the following:
    - Creates the container registry in the Client tenant.
    - Logs into the source registry tenant (i.e Arinco Tenant) and scans the registry for repositories and images
    - Logs into the target registry tenant (i.e Client Tenant) and imports the images

  .PARAMETER AzureRegion
  Mandatory. The name of the azure region to create the container registry.

  .PARAMETER SourceRegistryName
  Optional. The name of the source container registry to copy images from. Defaults to Arinco Container Registry name.

  .PARAMETER SourceTenantId
  Optional. The tenant id where the source container registry is located. Defaults to Arinco Production TenantId.

  .PARAMETER TargetRegistryName
  Mandatory. The name of the target container registry to copy images to.

  .PARAMETER TargetTenantId
  Mandatory. The tenant id where the target container registry is located.

  .PARAMETER TargetSubscriptionName
  Mandatory. The name of the subscription where the target container registry is located.

  .PARAMETER TargetRegistryResourceGroupName
  Mandatory. The name of the resource group where the target container registry is created.

  .EXAMPLE
    Build-Registry -AzureRegion australiaeast -TargetRegistryName msaebicepregistryacr -TargetTenantId 5be09980-4733-4c85-bebb-8c68f87d8ec0 -TargetSubscriptionName ms-platform-sub -TargetRegistryResourceGroupName ms-aue-bicep-registry-rg


  .NOTES
    Version:	1.0
    Author:		Scott Wilkinson

    Creation Date:			24/03/2023
    Purpose/Change:			Initial script development

    Required Modules:       None

    Dependencies: Azure CLI

    Limitations:  None

    Version History:  [24/03/2023 - 1.0 - Scott Wilkinson]: Initial script development

#>
function Build-Registry {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string] $AzureRegion,
    [Parameter(Mandatory = $false)]
    [string] $SourceRegistryName = "prdarincobicepmodulesacr",
    [Parameter(Mandatory = $false)]
    [string] $SourceTenantId = "e27c8f55-2c8d-4851-8059-1199a3dab677",
    [Parameter(Mandatory = $true)]
    [string] $TargetRegistryName,
    [Parameter(Mandatory = $true)]
    [string] $TargetTenantId,
    [Parameter(Mandatory = $true)]
    [string] $TargetSubscriptionName,
    [Parameter(Mandatory = $true)]
    [string] $TargetRegistryResourceGroupName
  )
  $ErrorActionPreference = "Stop"

  $SourceRegistryToken = ConnectToSourceRegistry -SourceTenantId  $SourceTenantId -SourceRegistryName $SourceRegistryName
  $Images = GetSourceRegistryImages -SourceRegistryName $SourceRegistryName

  CreateRegistry -AzureRegion $AzureRegion -TargetRegistryName $TargetRegistryName -TargetTenantId $TargetTenantId  -TargetSubscriptionName $TargetSubscriptionName -TargetRegistryResourceGroupName $TargetRegistryResourceGroupName
  ImportImagesToTargetRegistry -SourceRegistryToken $SourceRegistryToken -SourceRegistryName $SourceRegistryName -Images $Images -TargetTenantId $TargetTenantId -TargetSubscriptionName $TargetSubscriptionName -TargetRegistryName $TargetRegistryName
}

function CreateRegistry() {
  param (
    [Parameter(Mandatory = $true)]
    [string] $AzureRegion,
    [Parameter(Mandatory = $true)]
    [string] $TargetRegistryName,
    [Parameter(Mandatory = $true)]
    [string] $TargetTenantId,
    [Parameter(Mandatory = $true)]
    [string] $TargetSubscriptionName,
    [Parameter(Mandatory = $true)]
    [string] $TargetRegistryResourceGroupName
  )
  $ErrorActionPreference = "Stop"

  $account = az account show | ConvertFrom-Json
  if ($account.tenantId -ne $TargetTenantId) {
    Read-Host -Prompt "Prepare to login to tenant ($TargetTenantId) where the target registry '$TargetRegistryName' is located. Press any key to continue"
    try {
      az login --tenant $TargetTenantId 1>$null 2>$null
    }
    catch {
      throw "Failed to login to source tenant $TargetTenantId. Please ensure the correct credentials have been used. Error: $($_.Exception.Message)"
    }
  }

  try {
    az account set --subscription $TargetSubscriptionName
  }
  catch {
    throw "Failed to set subscription to $TargetSubscriptionName. Please ensure the correct subscription has been used. Error: $($_.Exception.Message)"
  }

  try {
    Write-Host "Provisioning registry"
    $output = az deployment sub create --template-file .\registry.bicep -l $AzureRegion --parameters location=$AzureRegion resourceGroupName=$TargetRegistryResourceGroupName containerRegistryName=$TargetRegistryName | ConvertFrom-Json
    if ($output.properties.provisioningState -eq "Succeeded") {
      Write-Host "Successfully provisioned registry"
    }
    else {
      $output
      throw "Provision state is $output.provisioningState. Please check output"
    }
  }
  catch {
    throw "Failed to deploy registry against target subscription $TargetSubscriptionName. Error: $($_.Exception.Message)"
  }
}

function ConnectToSourceRegistry {
  param (
    [Parameter(Mandatory = $true)]
    [string] $SourceRegistryName,
    [Parameter(Mandatory = $true)]
    [string] $SourceTenantId
  )

  $account = az account show | ConvertFrom-Json
  if ($account.tenantId -ne $SourceTenantId) {
    Read-Host -Prompt "Prepare to login to tenant ($SourceTenantId) where the source registry '$SourceRegistryName' is located. Press any key to continue"
    try {
      az login --tenant $SourceTenantId 1>$null 2>$null
    }
    catch {
      throw "Failed to login to source tenant $SourceTenantId. Please ensure the correct credentials have been used. Error: $($_.Exception.Message)"
    }
  }
  try {
    Write-Host "Connecting to source registry $SourceRegistryName."
    $Token = az acr login -n $SourceRegistryName --expose-token 2>$null | ConvertFrom-Json
    return $Token
  }
  catch {
    throw "Failed to login to source container registry $SourceRegistryName. Please ensure the correct credentials have been used. Error: $($_.Exception.Message)"
  }
}

function GetSourceRegistryImages {
  [OutputType('System.Collections.ArrayList')]
  param (
    [Parameter(Mandatory = $true)]
    [string] $SourceRegistryName
  )
  $Repos = az acr repository list -n $SourceRegistryName | ConvertFrom-Json
  Write-Host "Found $($($Repos).Count) source repositories."
  $Images = [System.Collections.ArrayList]@()

  Write-Host "Scanning source repositories for images."
  foreach ($Repo in $Repos) {
    $Tags = az acr repository show-tags -n $SourceRegistryName --repository $Repo | ConvertFrom-Json
    foreach ($Tag in $Tags) {
      $Images += "${Repo}:${Tag}"
    }
  }
  return $Images
}

function ImportImagesToTargetRegistry {
  param (
    [Parameter(Mandatory = $true)]
    $SourceRegistryToken,
    [Parameter(Mandatory = $true)]
    [string] $TargetTenantId,
    [Parameter(Mandatory = $true)]
    [string] $TargetSubscriptionName,
    [Parameter(Mandatory = $true)]
    [string] $TargetRegistryName,
    [Parameter(Mandatory = $true)]
    [string] $SourceRegistryName,
    [Parameter(Mandatory = $true)]
    [System.Collections.ArrayList] $Images
  )

  $account = az account show | ConvertFrom-Json
  if ($account.tenantId -ne $TargetTenantId) {
    Read-Host -Prompt "Prepare to login to tenant ($TargetTenantId) where target registry '$TargetRegistryName' is located. Press any key to continue"
    try {
      az login --tenant $TargetTenantId 1>$null 2>$null
    }
    catch {
      throw "Failed to login to target tenant $TargetTenantId. Please ensure the correct credentials have been used. Error: $($_.Exception.Message)"
    }
  }

  try {
    az account set --subscription $TargetSubscriptionName
  }
  catch {
    throw "Failed to locate target subscription $TargetSubscriptionName. Please ensure the target subscription name is correct. Error: $($_.Exception.Message)"
  }

  Write-Host "Importing images to target registry"

  foreach ($Image in $Images) {
    Write-Host "Importing Image $Image"

    try {
      az acr import -n $TargetRegistryName --force --source "$SourceRegistryName.azurecr.io/$Image" -u "00000000-0000-0000-0000-000000000000" -p $SourceRegistryToken.accessToken
    }
    catch {
      throw "Failed to import image from source registry $SourceRegistryName to $TargetRegistryName. Please ensure the target registry name is valid. Error: $($_.Exception.Message)"
    }
  }
}
