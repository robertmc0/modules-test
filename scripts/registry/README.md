# Bicep Modules Registry Bootstrap

The purpose of the scripts is to create initial resources in the client subscription to allow 'Done Right' deployments to utilise the bicep modules directly from a registry.

## Steps

1. Open command prompt to the directory containing this README.

2. Run the following commands and fill in the parameters in angle brackets.

```powershell
Import-Module .\Build-Registry.ps1 -Force
Build-Registry -AzureRegion <Region> -TargetRegistryName <Client registry name> -TargetTenantId <Client Tenant ID>  -TargetSubscriptionName <Client Subscription ID> -TargetRegistryResourceGroupName <Client registry resource group>
```

You will need:-

- AzureRegion. i.e australiaeast
- TargetRegistryName. Name must not contain spaces or symbols. i.e \<companyPrefix\>\<locationIdentifier\>bicepmodulesacr
- TargetTenantId
- TargetSubscriptionName
- TargetRegistryResourceGroupName i.e \<companyPrefix\>-\<locationIdentifier\>-bicep-registry-rg

3. In the 'Done Right' deployment repository modify the **bicepconfig.json** file to point to the clients bicep registry where the registry name is '\<companyPrefix\>\<locationIdentifier\>bicepmodulesacr'.

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

4. Execute 'Done Right' deployment.
