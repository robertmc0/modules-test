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

## Replace with your Customer's Azure DevOps URL for modules folder. e.g. https://dev.azure.com/mohammedshafayat/_git/bicep-templates?path=/modules
$devopsUrl = "https://dev.azure.com/contoso/Contoso/_git/Contoso-Modules?path=/modules"

# Set the git configuration on the DevOps agent.
# Note: There is no need to replace the email and name with your own.
# The DevOps agent just needs a placeholder email address for the local git profile.
git config --local user.email "bicep@module.update"
git config --local user.name "Bicep Modules"

git checkout main
git checkout -b refreshmoduletable



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
    $moduleRootUrl = "$devopsUrl/$modulePath"

    # Create the code and readme links
    $codeLink = "[🦾 Code]($moduleRootUrl/main.bicep)"
    $readmeLink = "[📃 Readme]($moduleRootUrl/README.md)"

    # Create a row for the module
    $tableData += , @($modulePath, $version, $codeLink, $readmeLink)
  }
}

# Convert the table data to a markdown table
$newTable = ConvertTo-MarkdownTable -Data $tableData

# Update the README.md file with the new table
Set-Content -Path "README.md" -Value $newTable

Write-Host "Updated README.md"

git add README.md

# 4. Commit the changes
git commit -m "Updated README.md"

git push origin refreshmoduletable


#Login to Azure Devops using environment variable
$accessToken = $env:AZURE_DEVOPS_EXT_PAT
$organizationUrl = $env:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI
$accessToken | az devops login --organization $organizationUrl

Write-Host "Logged in to Azure DevOps $organizationUrl"

# Create a pull request

az repos pr create --description "Refresh module table" --source-branch refreshmoduletable --target-branch main --title "Refresh module table" --auto-complete $true --merge-commit-message "refreshmoduletable branch merged to main" --delete-source-branch $true

az devops logout
