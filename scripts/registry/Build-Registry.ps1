#requires -Version 7.0
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
  Mandatory. The tenant id where the source container registry is located. This is usually the Arinco Tenant Id.

  .PARAMETER TargetRegistryName
  Mandatory. The name of the target container registry to copy images to.

  .PARAMETER TargetTenantId
  Mandatory. The tenant id where the target container registry is located.

  .PARAMETER TargetSubscriptionName
  Mandatory. The name of the subscription where the target container registry is located.

  .PARAMETER TargetRegistryResourceGroupName
  Mandatory. The name of the resource group where the target container registry is created.

  .PARAMETER ParallelisationFactor
  Optional. The number of parallel threads to use when scanning & importing images. Defaults to 30.

  .EXAMPLE
    Build-Registry -AzureRegion australiaeast -SourceTenantId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -TargetRegistryName msaebicepregistryacr -TargetTenantId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -TargetSubscriptionName ms-platform-sub -TargetRegistryResourceGroupName ms-aue-bicep-registry-rg


  .NOTES
    Version:	1.3
    Author:		Scott Wilkinson

    Creation Date:			24/03/2023
    Purpose/Change:			Initial script development

    Required Modules:       None

    Dependencies: Azure CLI

    Limitations:  None

    Version History:
      [24/03/2023 - 1.0 - Scott Wilkinson]: Initial script development
      [17/05/2023 - 1.1 - Scott Wilkinson]: Added enhancements to supporting uplifting a registry with new module versions
      [10/08/2023 - 1.2 - AJ Bajada]: Added check for existing Azure container registry
      [01/04/2024 - 1.3 - Ben Ranford]: Added support for parallel scanning/importing
      [13/08/2024 - 1.4 - Scott Wilkinson]: Removed tenant ids.

#>
function Build-Registry {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory = $true)]
    [string] $AzureRegion,
    [Parameter(Mandatory = $false)]
    [string] $SourceRegistryName = "prdarincobicepmodulesacr",
    [Parameter(Mandatory = $false)]
    [string] $SourceTenantId,
    [Parameter(Mandatory = $true)]
    [string] $TargetRegistryName,
    [Parameter(Mandatory = $true)]
    [string] $TargetTenantId,
    [Parameter(Mandatory = $true)]
    [string] $TargetSubscriptionName,
    [Parameter(Mandatory = $true)]
    [string] $TargetRegistryResourceGroupName,
    [Parameter(Mandatory = $false)]
    [string] $Tags = "{}",
    [Parameter(Mandatory = $false)]
    [int] $ParallelisationFactor = 30

  )
  $ErrorActionPreference = "Stop"

  $SourceRegistryToken = ConnectToSourceRegistry -SourceTenantId  $SourceTenantId -SourceRegistryName $SourceRegistryName
  $Images = GetSourceRegistryImages -SourceRegistryName $SourceRegistryName

  CreateRegistry -AzureRegion $AzureRegion -TargetRegistryName $TargetRegistryName -TargetTenantId $TargetTenantId  -TargetSubscriptionName $TargetSubscriptionName -TargetRegistryResourceGroupName $TargetRegistryResourceGroupName -Tags $Tags
  ImportImagesToTargetRegistry -SourceRegistryToken $SourceRegistryToken -SourceRegistryName $SourceRegistryName -Images $Images -TargetTenantId $TargetTenantId -TargetSubscriptionName $TargetSubscriptionName -TargetRegistryName $TargetRegistryName

  Write-Host "Registry build and import process was successful"
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
    Write-Host "Connecting to source registry $SourceRegistryName"
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
  Write-Host "Found $($($Repos).Count) modules in source registry"
  $Images = [System.Collections.ArrayList]@()

  Write-Host "Scanning modules for versions with" $ParallelisationFactor "threads"
  $Images = $Repos | ForEach-Object -Parallel {
    $Repo = $_
    $SourceRegistryName = $using:SourceRegistryName
    $Tags = az acr repository show-tags -n $SourceRegistryName --repository $Repo | ConvertFrom-Json
    foreach ($Tag in $Tags) {
      "${Repo}:${Tag}"
    }
  }
  return $Images
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
    [string] $TargetRegistryResourceGroupName,
    [Parameter(Mandatory = $false)]
    [string] $Tags
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
    $checkAcrExists = az acr show --name $TargetRegistryName --resource-group $TargetRegistryResourceGroupName 2>nul
    if ($checkAcrExists) {
      Write-Host "Skipping as registry already exists"
    }
    else {
      $output = az deployment sub create --template-file .\registry.bicep -l $AzureRegion --parameters location=$AzureRegion resourceGroupName=$TargetRegistryResourceGroupName containerRegistryName=$TargetRegistryName tags=$Tags | ConvertFrom-Json
      if ($output.properties.provisioningState -eq "Succeeded") {
        Write-Host "Successfully provisioned target registry"
      }
      else {
        $output
        throw "Provision failed. Please check output"
      }
    }
  }
  catch {
    throw "Failed to deploy registry against target subscription $TargetSubscriptionName. Error: $($_.Exception.Message)"
  }
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

  Write-Host "Connecting to target registry $TargetRegistryName"
  $Repos = az acr repository list -n $TargetRegistryName | ConvertFrom-Json

  if (($($Repos).Count) -ne 0) {
    Write-Host "Found $($($Repos).Count) modules in target registry"
    $TargetImages = [System.Collections.ArrayList]@()

    Write-Host "Scanning modules for versions"
    foreach ($Repo in $Repos) {
      $Tags = az acr repository show-tags -n $TargetRegistryName --repository $Repo | ConvertFrom-Json
      foreach ($Tag in $Tags) {
        $TargetImages += "${Repo}:${Tag}"
      }
    }

    Write-Host "Calculating differences between source and target registries"

    $newImages = $Images | Select-Object -Unique | Where-Object { $TargetImages -notcontains $_ }

    Write-Host "$($($newImages).Count) new version(s) identified"
  }
  else {
    $newImages = $Images
  }

  if ($($newImages).Count -ne 0) {
    Write-Host "Importing module versions to target registry"

    $newImages | ForEach-Object  -ThrottleLimit $ParallelisationFactor -Parallel {
      $Image = $_
      $TargetRegistryName = $using:TargetRegistryName
      $SourceRegistryName = $using:SourceRegistryName
      $SourceRegistryToken = $using:SourceRegistryToken
      $TargetRegistryResourceGroupName = $using:TargetRegistryResourceGroupName

      Write-Host "Importing $Image"
      try {
        az acr import -n $TargetRegistryName --force --source "$SourceRegistryName.azurecr.io/$Image" -u "00000000-0000-0000-0000-000000000000" -p $SourceRegistryToken.accessToken --resource-group $TargetRegistryResourceGroupName
      }
      catch {
        throw "Failed to import module from source registry $SourceRegistryName to $TargetRegistryName. Please ensure the target registry name is valid. Error: $($_.Exception.Message)"
      }
    }
  }
}
