#requires -version 6.0
<#
  .SYNOPSIS
    Script used to copy bice moduls from a azure container registry to another registry in a different tenant. The script uses AD Authentication to access
    the source registry.

  .DESCRIPTION
    This script does the following:
    - Logs into the source registry tenant (i.e Arinco Tenant) and scans the registry for repositories and images
    - Logs into the target registry tenant (i.e Client Tenant) and imports the images

  .EXAMPLE
    .\scripts\copy-registry.ps1 -TargetRegistryName trgtregistry -TargetTenantId <TRGT_TENANT_ID>  -TargetSubscriptionName <TRGT_SUB_NAME>


  .NOTES
    Version:	1.0
    Author:		Scott Wilkinson

    Creation Date:			16/02/2023
    Purpose/Change:			Initial script development

    Required Modules:       None

    Dependencies: Azure CLI

    Limitations:  None

    Version History:  [16/02/2023 - 1.0 - Scott Wilkinson]: Initial script development

#>
[CmdletBinding()]
param (
  [Parameter(Mandatory = $false)]
  [string] $SourceRegistryName = "prdarincobicepmodulesacr",
  [Parameter(Mandatory = $false)]
  [string] $SourceTenantId = "e27c8f55-2c8d-4851-8059-1199a3dab677",
  [Parameter(Mandatory = $true)]
  [string] $TargetRegistryName,
  [Parameter(Mandatory = $true)]
  [string] $TargetTenantId,
  [Parameter(Mandatory = $true)]
  [string] $TargetSubscriptionName
)
$ErrorActionPreference = "Stop"

Read-Host -Prompt "Prepare to login to tenant ($SourceTenantId) where the source registry '$SourceRegistryName' is located. Press any key to continue"
az login --tenant $SourceTenantId 1>$null 2>$null
$token = az acr login -n $SourceRegistryName --expose-token 2>$null | ConvertFrom-Json
$Repos = az acr repository list -n $SourceRegistryName | ConvertFrom-Json

Write-Host "Found $($($Repos).Count) source repositories."
$images = [System.Collections.ArrayList]@()

Write-Host "Scanning source repositories for images."
foreach ($repo in $Repos) {
  $Tags = az acr repository show-tags -n $SourceRegistryName --repository $repo | ConvertFrom-Json
  foreach ($tag in $Tags) {
    $images += "${repo}:${tag}"
  }
}

Read-Host -Prompt "Prepare to login to tenant ($TargetTenantId) where target registry '$TargetRegistryName' is located. Press any key to continue"
az login --tenant $TargetTenantId 1>$null 2>$null
az account set --subscription $TargetSubscriptionName

Write-Host "Importing images to target registry"

foreach ($image in $images) {
  Write-Host "Importing Image $image"
  az acr import -n $TargetRegistryName --force --source "$SourceRegistryName.azurecr.io/$image" -u "00000000-0000-0000-0000-000000000000" -p $token.accessToken
}
