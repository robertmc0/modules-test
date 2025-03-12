[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $ModuleTag,
  [Parameter()]
  [string]
  $RegistryServer
)

#Subscription ID of the Azure Container Registry
Set-AzContext -Subscription "<replace with customer subscription id>"

$currentRef = git symbolic-ref --short HEAD
Write-Host "Current reference: $currentRef"
$rootPath = Get-Location

if (!$RegistryServer) {
  $RegistryServer = Get-Content .registry-server
}

if (!$ModuleTag) {
  $ModuleTag = Get-Content .module-tag
}

git checkout $ModuleTag

$moduleTagParts = $ModuleTag -split '/'
$moduleId = ($moduleTagParts | Select-Object -SkipLast 1) -join '/'
$moduleVersion = $moduleTagParts | Select-Object -Last 1
$modulePath = "modules/$moduleId/main.bicep"
$moduleUrl = "br:$RegistryServer/bicep/$($moduleId):$($moduleVersion)"

Write-Host "Tag: $ModuleTag"
Write-Host "Identifier: $moduleId"
Write-Host "Version: $moduleVersion"
Write-Host "Path: $modulePath"
Write-Host "URL: $moduleUrl"

bicep --version
az bicep upgrade
bicep publish $modulePath --target $moduleUrl --with-source

Write-Host "Successfully published module: $moduleUrl"

Set-Location $rootPath
git checkout $currentRef