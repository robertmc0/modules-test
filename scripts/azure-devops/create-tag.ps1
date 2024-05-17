[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $OldRevision,
  [Parameter()]
  [string]
  $NewRevision,
  [Parameter()]
  [string]
  $Tag
)

$currentRef = git symbolic-ref --short HEAD
$rootPath = Get-Location

git checkout $ModuleTag

if (!$NewRevision) {
  $NewRevision = $currentRef
}
$NewRevision = $NewRevision -replace 'refs/heads', 'remotes/origin'

if (!$OldRevision) {
  $OldRevision = git merge-base $NewRevision "$NewRevision~1"
}

$modulePath = Get-Content .module-path
$moduleName = ($modulePath -replace '\\', '/') -replace 'modules/', ''

Set-Location $modulePath

Write-Host "Module Name: $($moduleName)"
Write-Host "Module Path: $($modulePath)"
Write-Host "Old Revision: $($OldRevision)"
Write-Host "New Revision: $($NewRevision)"

$Env:PublicRelease = $true

$oldVersion = nbgv get-version $OldRevision --format json `
| ConvertFrom-Json `
| Select-Object -ExpandProperty SemVer2

$newVersion = nbgv get-version $NewRevision --format json `
| ConvertFrom-Json `
| Select-Object -ExpandProperty SemVer2

Write-Host "New Version: $newVersion"
Write-Host "Old Version: $oldVersion"

semver-compare $newVersion $oldVersion

if ($Tag -or $LASTEXITCODE -eq 1) {
  $Tag = if ($Tag) { $Tag } else { "$moduleName/$newVersion" }
  git tag $Tag
  # git push origin $Tag
  # if (!$?) {
  #   throw "Failed to push tag $tag."
  # }
  $tag | Out-File "$rootPath/.module-tag"
  Write-Host "Created tag $tag"
}
else {
  Write-Host "No version update present. Creation of release $newVersion skipped."
}

Set-Location $rootPath
