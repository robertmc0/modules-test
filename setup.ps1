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

#>

<##====================================================================================
	GLOBAL VARIABLES
##===================================================================================#>
### Possible improvement to dynmaically get the download URL ###
$dotnetFilename = "dotnet_installer.exe"
$dotnetRemoteURL = "https://download.visualstudio.microsoft.com/download/pr/175ea216-cfde-4fab-8184-c19ce4c1e349/05f550b728c9f53e3e14ec54f40f42aa/dotnet-runtime-6.0.7-win-x64.exe"

$npmFilename = "npm_installer.msi"
$npmRemoteURL = "https://nodejs.org/dist/v16.16.0/node-v16.16.0-x64.msi"

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
    $version = dotnet --version
    if ($version[0] -ne '6') {
      throw "incorrect version"
    }
  }
  catch {
    Write-Output ".NET6 not found, downloading and installing"
    Invoke-WebRequest $dotnetRemoteURL -OutFile $dotnetFilename
    Start-Process ./$dotnetFilename -ArgumentList '/passive' -Wait
  }
  finally {
    ### install brm ###
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
    throw "test error"
  }
  catch {
    Write-Output "npm not found, downloading and installing"
    Invoke-WebRequest $npmRemoteURL -OutFile $npmFilename
    Start-Process ./$npmFilename -ArgumentList '/passive' -Wait
  }
  finally {
    npm install
  }
}

function install_vscode_extension() {
  <#
    .SYNOPSIS
      Install vscode extension

    .DESCRIPTION
      Install vscode extension
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
install_dotnet
install_npm
install_vscode_extension
cleanup