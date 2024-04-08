# Bicep Modules Registry Bootstrap

The purpose of the scripts is to create initial resources in the client subscription to allow 'Done Right' deployments to utilise the bicep modules directly from a registry. The scripts can also be rerun to uplift an existing registry with new module versions.

Permissions:

| Task                   | Role Assignment | Description                                             |
| ---------------------- | --------------- | ------------------------------------------------------- |
| Create ACR and Modules | Contributor     | Required to run the script and create the ACR resource. |
| Pull Bicep Modules     | AcrPull         | Required to pull the bicep modules from the registry.   |
| Update Bicep Modules   | Contributor     | Required to run the script and update the ACR resource. |

The role assignment `Contributor` is required to run the script and create the ACR resource. The role assignment `AcrPull` is required to pull the bicep modules from the registry.

The Azure RBAC permission `Microsoft.ContainerRegistry/registries/importImage/action` allows a user or service principal to import an image into an Azure Container Registry (ACR). This permission is required to perform the `az acr import` command, which imports an image from a specified source to an ACR repository. The rbac role of `Contributor` includes this permission.

Required Parameters:

- AzureRegion. i.e australiaeast
- TargetRegistryName. Name must not contain spaces or symbols. i.e \<companyPrefix\>\<locationIdentifier\>bicepmodulesacr
- TargetTenantId
- TargetSubscriptionName
- TargetRegistryResourceGroupName i.e \<companyPrefix\>-\<locationIdentifier\>-bicep-registry-rg

Optional Parameters:

- Tags. Needs to be a JSON formatted string. i.e "{'Owner':'Contoso','Cost Center':'2345-324'}"
- ParallelisationFactor (A number, i.e. 15 - defaults to 30 if not set)

## Steps

1. Open command prompt to the directory containing this README.

2. If the command prompt does not have adminstration privelges, run the following script to ensure powershell can execute unsigned scripts.

```powershell
Set-ExecutionPolicy Unrestricted -Scope CurrentUser
```

3. Run the following commands and fill in the parameters in angle brackets.

```powershell
Import-Module .\Build-Registry.ps1 -Force
Build-Registry -AzureRegion <Region> -TargetRegistryName <Client registry name> -TargetTenantId <Client Tenant ID>  -TargetSubscriptionName <Client Subscription ID> -TargetRegistryResourceGroupName <Client registry resource group> -Tags <Tags>
```

4. In the 'Done Right' deployment repository modify the **bicepconfig.json** file to point to the clients bicep registry where the registry name is '\<companyPrefix\>\<locationIdentifier\>bicepmodulesacr'.

```json
{
  "moduleAliases": {
    "br": {
      "ArincoModules": {
        "registry": "<client registry name>.azurecr.io",
        "modulePath": "bicep"
      }
    }
  }
}
```

5. Ensure the service principal used to deploy the 'Done Right' solution has the acrPull role assignment against the container registry.
6. Execute 'Done Right' deployment.
