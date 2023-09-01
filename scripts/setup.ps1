<#
  .SYNOPSIS
    Setup script for the arinco bicep github repo

  .DESCRIPTION
    This script will download and install the following if they are not already present
      .NET6
      NPM
      Azure Bicep Registry Module Tool
      VSCode extension for Prettier
      VSCode extension for Bicep
      All node modules within this repo

  .EXAMPLE
    .\setup.ps1

  .NOTES
    Version:	1.0
    Author:		Sunny Liu

    Creation Date:			02/08/2022
    Purpose/Change:			Initial script development

    Required Modules:       None

    Dependencies: VS Code is already installed

    Limitations:  None

    Supported Platforms*:   Windows x64

    Version History:  [02/08/2022 - 1.0 - Sunny Liu]: Initial script development
                      [31/08/2023 - 1.1 - Suhail Nepal]: Update .Net and node version and apply fixes

#>

<##====================================================================================
	GLOBAL VARIABLES
##===================================================================================#>
### Possible improvement to dynmaically get the download URL ###
$dotnetFilename = "dotnet_installer.exe"
$dotnetRemoteURL = "https://download.visualstudio.microsoft.com/download/pr/e3f91c3f-dbcc-44cb-a319-9cb15c9b61b9/6c87d96b2294afed74ccf414e7747b5a/dotnet-sdk-7.0.400-win-x64.exe"

$npmFilename = "npm_installer.msi"
$npmRemoteURL = "https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi"

<##====================================================================================
	FUNCTIONS
##===================================================================================#>

function install_dotnet() {
  <#
    .SYNOPSIS
      Install dotnet

    .DESCRIPTION
      Install dotnet
  #>
  try {
    $versionCheck = $false
    $versions = dotnet --list-sdks
    foreach ($version in $versions) {
      if ($version[0] -notmatch '^7\..*') {
        $versionCheck = $true
        break
      }
    }
    if (!$versionCheck) {
      throw ".NET version 7 not found"
    }
  }
  catch {
    Write-Output ".NET7 not found, downloading and installing"
    Invoke-WebRequest $dotnetRemoteURL -OutFile $dotnetFilename
    Start-Process ./$dotnetFilename -ArgumentList '/passive' -Wait
  }
}

function install_brm() {
  <#
    .SYNOPSIS
      Install brm

    .DESCRIPTION
      Install brm
  #>
  try {
    brm --version
  }
  catch {
    Write-Output "brm not found, installing"
    dotnet tool install --global Azure.Bicep.RegistryModuleTool
  }
}


function install_npm() {
  <#
    .SYNOPSIS
      Install npm

    .DESCRIPTION
      Install npm
  #>
  try {
    npm --version
  }
  catch {
    Write-Output "npm not found, downloading and installing"
    Invoke-WebRequest $npmRemoteURL -OutFile $npmFilename
    $process = Start-Process ./$npmFilename -ArgumentList '/passive' -PassThru
    $process.WaitForExit()
  }
}

function install_vscode_extension() {
  <#
    .SYNOPSIS
      Install vscode extension

    .DESCRIPTION
      Install vscode extension. As a pre-req Visual Studio Code must be installed before executing this script.
  #>
  code --install-extension esbenp.prettier-vscode
  code --install-extension ms-azuretools.vscode-bicep
}
function cleanup() {
  <#
    .SYNOPSIS
      Remove installer files

    .DESCRIPTION
      Remove installer files
  #>
  Write-Output "Installation complete, deleting installer files"
  if (Test-Path $dotnetFilename) {
    Remove-Item $dotnetFilename
  }
  if (Test-Path $npmFilename) {
    Remove-Item $npmFilename
  }
}

<##====================================================================================
	MAIN CODE
##===================================================================================#>

try {
  install_dotnet
  install_brm
  install_npm
  install_vscode_extension
}
finally {
  cleanup
}