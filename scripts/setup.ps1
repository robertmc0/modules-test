<#
  .SYNOPSIS
    Setup script for the arinco bicep github repo

  .DESCRIPTION
    This script will download and install the following if they are not already present
      .NET7
      NPM
      Azure Bicep Registry Module Tool
      VSCode extension for Prettier
      VSCode extension for Bicep
      All node modules within this repo

  .EXAMPLE
    .\setup.ps1

  .NOTES
    Version:	1.2
    Author:		Sunny Liu, Suhail Nepal, Ben Ranford

    Creation Date:			02/08/2022
    Purpose/Change:			Initial script development

    Required Modules:       None

    Dependencies: VS Code is already installed

    Limitations:  None

    Supported Platforms*:   Windows x64, macOS arm64

    Version History:  [02/08/2022 - 1.0 - Sunny Liu]: Initial script development
                      [31/08/2023 - 1.1 - Suhail Nepal]: Update .Net and node version and apply fixes
                      [17/10/2024 - 1.2 - Ben Ranford]: Update brm install script as wait-process cannot bind to dotnet install. add more error handling.

#>

<##====================================================================================
	GLOBAL VARIABLES
##===================================================================================#>
$dotnetFilename = "dotnet_installer.exe"
$dotnetRemoteURL = "https://download.visualstudio.microsoft.com/download/pr/e3f91c3f-dbcc-44cb-a319-9cb15c9b61b9/6c87d96b2294afed74ccf414e7747b5a/dotnet-sdk-7.0.400-win-x64.exe"

$npmFilename = "npm_installer.msi"
$npmRemoteURL = "https://nodejs.org/dist/v18.17.1/node-v18.17.1-x64.msi"

<##====================================================================================
	FUNCTIONS
##===================================================================================#>

function install_dotnet() {
  try {
    $versionCheck = $false
    $versions = dotnet --list-sdks
    foreach ($version in $versions) {
      if ($version[0] -match '^7\..*') {
        $versionCheck = $true
        break
      }
    }
    if (!$versionCheck) {
      throw ".NET version 7 not found"
    }
    Write-Output ".NET7 is already installed"
  }
  catch {
    Write-Output ".NET7 not found, downloading and installing"
    try {
      Invoke-WebRequest $dotnetRemoteURL -OutFile $dotnetFilename -ErrorAction Stop
      Start-Process ./$dotnetFilename -ArgumentList '/passive' -Wait -ErrorAction Stop
    }
    catch {
      Write-Error "Failed to download or install .NET7: $_"
      throw
    }
  }
}

function install_brm() {
  try {
    brm --version
    Write-Output "brm is already installed"
  }
  catch {
    Write-Output "brm not found, installing"
    try {
      Start-Process -FilePath "dotnet" -ArgumentList "nuget remove source https://api.nuget.org/v3/index.json -n nuget.org" -NoNewWindow -Wait -ErrorAction Stop
      Start-Process -FilePath "dotnet" -ArgumentList "tool install --global Azure.Bicep.RegistryModuleTool" -NoNewWindow -Wait -ErrorAction Stop
    }
    catch {
      Write-Error "Failed to install brm: $_"
      throw
    }
  }
}

function install_npm() {
  try {
    npm --version
    Write-Output "npm is already installed"
  }
  catch {
    Write-Output "npm not found, downloading and installing"
    try {
      Invoke-WebRequest $npmRemoteURL -OutFile $npmFilename -ErrorAction Stop
      $process = Start-Process ./$npmFilename -ArgumentList '/passive' -PassThru -ErrorAction Stop
      $process.WaitForExit()
    }
    catch {
      Write-Error "Failed to download or install npm: $_"
      throw
    }
  }
}

function install_vscode_extension() {
  try {
    code --version
  }
  catch {
    Write-Error "Visual Studio Code is not installed or not in PATH. Please install VS Code before running this script."
    throw
  }

  try {
    code --install-extension esbenp.prettier-vscode
    code --install-extension ms-azuretools.vscode-bicep
  }
  catch {
    Write-Error "Failed to install VS Code extensions: $_"
    throw
  }
}

function cleanup() {
  Write-Output "Installation complete, deleting installer files"
  if (Test-Path $dotnetFilename) {
    Remove-Item $dotnetFilename -ErrorAction SilentlyContinue
  }
  if (Test-Path $npmFilename) {
    Remove-Item $npmFilename -ErrorAction SilentlyContinue
  }
}

<##====================================================================================
	MAIN CODE
##===================================================================================#>

try {
  $ErrorActionPreference = "Stop"

  install_dotnet
  install_brm
  install_npm
  install_vscode_extension

  Write-Output "Setup completed successfully"
}
catch {
  Write-Error "An error occurred during setup: $_"
}
finally {
  cleanup
  $ErrorActionPreference = "Continue"
}