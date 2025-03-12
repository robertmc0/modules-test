<#
  .SYNOPSIS
    Cross-platform setup script for the arinco bicep github repo

  .DESCRIPTION
    This script will download and install the following if they are not already present:
      .NET 8
      Node.js and NPM
      Azure Bicep Registry Module Tool
      VSCode extension for Prettier
      VSCode extension for Bicep

  .EXAMPLE
    .\setup.ps1

  .NOTES
    Version: 2.1
    Author: Sunny Liu, Suhail Nepal, Ben Ranford

    Creation Date: 17/10/2024
    Purpose/Change: Cross-platform support for Windows and macOS, added support for VS Code Insiders

    Required Modules: None
    Dependencies: VS Code or VS Code Insiders is already installed
    Limitations: None
    Supported Platforms: Windows x64/arm64, macOS x64/arm64

    Version History:  [02/08/2022 - 1.0 - Sunny Liu]: Initial script development
                      [31/08/2023 - 1.1 - Suhail Nepal]: Update .Net and node version and apply fixes
                      [17/10/2024 - 2.0 - Ben Ranford]: Update brm install script as wait-process cannot bind to dotnet install. add more error handling. Bump .NET version to 8.0.10. Made cross platform and cross arch compatible. Added support for VS Code Insiders
#>

# Determine OS and architecture
$isArm64 = [System.Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -eq [System.Runtime.InteropServices.Architecture]::Arm64

# Set up variables based on OS and architecture
if ($isWindows) {
  if ($isArm64) {
    $dotnetUrl = "https://download.visualstudio.microsoft.com/download/pr/09b9c42b-8189-40e7-9033-45ac95e311b6/d30b6ee196576e7007aff16f3b2697a2/dotnet-runtime-8.0.10-win-arm64.exe"
    $nodeUrl = "https://nodejs.org/dist/v20.9.0/node-v20.9.0-arm64.msi"
  }
  else {
    $dotnetUrl = "https://download.visualstudio.microsoft.com/download/pr/f55ed80e-ba58-4ac8-a2b3-f2227cd628de/6fabf1c613cf9386d14ddbaaca1a5eb8/dotnet-runtime-8.0.10-win-x64.exe"
    $nodeUrl = "https://nodejs.org/dist/v20.9.0/node-v20.9.0-x64.msi"
  }
}
elseif ($isMacOS) {
  if ($isArm64) {
    $dotnetUrl = "https://download.visualstudio.microsoft.com/download/pr/fd2985f3-9c48-48f5-aa1f-b44048867c07/3900dd411441277fe4c01515ec099a50/dotnet-runtime-8.0.10-osx-arm64.pkg"
    $nodeUrl = "https://nodejs.org/dist/v20.9.0/node-v20.9.0-darwin-arm64.tar.gz"
  }
  else {
    $dotnetUrl = "https://download.visualstudio.microsoft.com/download/pr/39438218-9735-41f4-ae9d-12cde5faf85e/9c8ceefa41c57929ae626d5ff64d7b56/dotnet-runtime-8.0.10-osx-x64.pkg"
    $nodeUrl = "https://nodejs.org/dist/v20.9.0/node-v20.9.0-darwin-x64.tar.gz"
  }
}

function Install-DotNet {
  try {
    $versions = dotnet --list-sdks
    if ($versions -match '^8\..*') {
      Write-Output ".NET 8 is already installed"
      return
    }
  }
  catch {
    Write-Output ".NET 8 not found, downloading and installing"
  }

  $installerPath = Join-Path $env:TEMP "dotnet_installer$(if ($isWindows) {'.exe'} else {'.pkg'})"
  Invoke-WebRequest $dotnetUrl -OutFile $installerPath

  if ($isWindows) {
    Start-Process $installerPath -ArgumentList '/quiet' -Wait
  }
  else {
    sudo installer -pkg $installerPath -target /
  }

  Remove-Item $installerPath
}

function Install-NodeAndNpm {
  try {
    node --version
    npm --version
    Write-Output "Node.js and npm are already installed"
    return
  }
  catch {
    Write-Output "Node.js and npm not found, downloading and installing"
  }

  $installerPath = Join-Path $env:TEMP "node_installer$(if ($isWindows) {'.msi'} else {'.tar.gz'})"
  Invoke-WebRequest $nodeUrl -OutFile $installerPath

  if ($isWindows) {
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /qn" -Wait
  }
  else {
    sudo tar -xzf $installerPath -C /usr/local --strip-components 1
  }

  Remove-Item $installerPath
}

function Install-Brm {
  try {
    brm --version
    Write-Output "brm is already installed"
  }
  catch {
    Write-Output "brm not found, installing"
    dotnet tool install --global Azure.Bicep.RegistryModuleTool
  }
}

function Get-VsCodeCommand {
  $codeCommand = $null
  $codeInsidersCommand = $null

  try {
    code --version | Out-Null
    $codeCommand = "code"
  }
  catch {}

  try {
    code-insiders --version | Out-Null
    $codeInsidersCommand = "code-insiders"
  }
  catch {}

  if ($codeCommand -and $codeInsidersCommand) {
    $choice = Read-Host "Both VS Code and VS Code Insiders are installed. Which one would you like to use? (1 for VS Code, 2 for VS Code Insiders)"
    if ($choice -eq "2") {
      return $codeInsidersCommand
    }
    else {
      return $codeCommand
    }
  }
  elseif ($codeInsidersCommand) {
    return $codeInsidersCommand
  }
  elseif ($codeCommand) {
    return $codeCommand
  }
  else {
    Write-Error "Neither Visual Studio Code nor VS Code Insiders is installed or in PATH. Please install VS Code or VS Code Insiders before running this script."
    return $null
  }
}

function Install-VsCodeExtensions {
  $codeCommand = Get-VsCodeCommand
  if (-not $codeCommand) {
    return
  }

  & $codeCommand --install-extension esbenp.prettier-vscode
  & $codeCommand --install-extension ms-azuretools.vscode-bicep
}

try {
  $ErrorActionPreference = "Stop"

  Install-DotNet
  Install-NodeAndNpm
  Install-Brm
  Install-VsCodeExtensions

  Write-Output "Setup completed successfully"
}
catch {
  Write-Error "An error occurred during setup: $_"
}
finally {
  $ErrorActionPreference = "Continue"
}
