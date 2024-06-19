[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $ModuleTag,
  [Parameter()]
  [string]
  $RegistryServer
)

Set-AzContext -Subscription "fb707578-8b68-48d4-9ffa-adff9699d0fb"

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
$modulePath = "modules/$moduleId/main.json"
$moduleUrl = "br:$RegistryServer/bicep/$($moduleId):$($moduleVersion)"

Write-Host "Tag: $ModuleTag"
Write-Host "Identifier: $moduleId"
Write-Host "Version: $moduleVersion"
Write-Host "Path: $modulePath"
Write-Host "URL: $moduleUrl"

bicep --version
az bicep upgrade
bicep publish $modulePath --target $moduleUrl

Write-Host "Successfully published module: $moduleUrl"

Set-Location $rootPath
git checkout $currentRef