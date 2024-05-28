[CmdletBinding()]
param (
  [Parameter()]
  [string]
  $OldRevision,
  [Parameter()]
  [string]
  $NewRevision
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

Write-Host "Comparing changes between source branch $OldRevision and target branch $NewRevision"

$changedFiles = git diff --name-only "$NewRevision..$OldRevision"

$changedModules = $changedFiles `
| Where-Object { $_ -match "^modules/" } `
| ForEach-Object { ($_ -split "/")[0..2] -join "/" } `
| Select-Object -Unique

Write-Host "Changed Modules: $changedModules"

$changedModuleCount = ($changedModules | Measure-Object).Count

switch ($changedModuleCount) {
  0 { throw "No module changes detected. Expected exactly one module to be changed" }
  1 { ($changedModules | Select-Object -First 1) | Out-File -FilePath .module-path }
  Default { throw "$changedModuleCount module changes detected. Expected exactly one module to be changed" }
}

Write-Host "Identified changed module: $(Get-Content .module-path)"

Set-Location $rootPath
git checkout $currentRef