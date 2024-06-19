# Function to convert an array to a markdown table
function ConvertTo-MarkdownTable {
  param (
    [Parameter(Mandatory = $true)]
    [array]$Data
  )

  $header = $Data[0]
  $body = $Data[1..($Data.Length - 1)]

  # Create the header row
  $markdownTable = "| " + ($header -join " | ") + " |`n"

  # Create the separator row
  $markdownTable += "| --- | --- | --- | --- |`n"

  # Create the body rows
  foreach ($row in $body) {
    $markdownTable += "| " + ($row -join " | ") + " |`n"
  }

  return $markdownTable
}

# Set the git configuration on devops agent. no need to replace with your own email and name
git config --local user.email "you@example.com"
git config --local user.name "Your Name"

git checkout main
git checkout -b refreshmoduletable

# $rootPath = Get-Location
# Set-Location $rootPath

# Get all subdirectories in the modules directory
$moduleGroups = Get-ChildItem -Path "modules" -Directory

# Initialize an array to hold the table data
$tableData = @()
$tableData += , @("Modules", "Version", "Code", "Readme")

# Iterate over each module group
foreach ($moduleGroup in $moduleGroups) {
  # Get all subdirectories in the current module group directory
  $moduleNames = Get-ChildItem -Path $moduleGroup.FullName -Directory

  # Iterate over each module
  foreach ($moduleName in $moduleNames) {
    $modulePath = "$($moduleGroup.Name)/$($moduleName.Name)"

    # Get the latest version tag for the module
    # Get all tags for the module path, convert them to [System.Version] for sorting, then select the latest
    $tag = git tag --list "$modulePath/*" |
    ForEach-Object { $_ -replace "$modulePath/", "" } | # Remove the module path prefix
    Where-Object { $_ -match '^\d+\.\d+\.\d+$' } | # Ensure only valid semver tags are considered
    ForEach-Object { [System.Version]$_ } | # Convert to [System.Version] for proper comparison
    Sort-Object -Descending |
    Select-Object -First 1 |
    ForEach-Object { "$modulePath/$_" } # Re-add the module path prefix to the version
    # Extract the version from the tag
    $version = $tag -split '/' | Select-Object -Last 1

    # Create the module root URL
    $moduleRootUrl = "https://dev.azure.com/mohammedshafayat/bicep-modules/_git/bicep-modules?path=/modules/$modulePath"

    # Create the code and readme links
    $codeLink = "[🦾 Code]($moduleRootUrl/main.bicep)"
    $readmeLink = "[📃 Readme]($moduleRootUrl/README.md)"

    # Create a row for the module
    $tableData += , @($modulePath, $version, $codeLink, $readmeLink)
  }
}

# Convert the table data to a markdown table
$newTable = ConvertTo-MarkdownTable -Data $tableData

# Write the new table to the readmeupdate.md file
# Set-Content -Path "readmeupdate.md" -Value $newTable
Set-Content -Path "README.md" -Value $newTable

Write-Host "Updated README.md"

git add .

# 4. Commit the changes
git commit -a -m "Updated README.md"

git push origin refreshmoduletable


#Login to Azure Devops using environment variable
$accessToken = $env:AZURE_DEVOPS_EXT_PAT
$organizationUrl = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$accessToken | az devops login --organization $organizationUrl

Write-Host "Logged in to Azure DevOps $organizationUrl"

# Create a pull request

az repos pr create --description "Refresh module table" --source-branch refreshmoduletable --target-branch main --title "Refresh module table" --auto-complete $true --merge-commit-message "refreshmoduletable branch merged to main" --delete-source-branch $true

az devops logout


# Write-Host "Creating pull request to refresh module table"

# Get-AzResourceGroup

# Write-Host "Successfully created pull request to refresh module table"
