## Azure Devops Instructions

#### NOTE

##### In order to update the README.md table with the latest version of the module, we are using Git tags on the repo to track the module versions. The following steps need to be completed when copying the Arinco modules from Arinco's GitHub repository to ensure that the tags from our repo are copied over to the customer's DevOps repository. Step 8 provides the build service with the necessary permissions to update the README.md table. The README.MD table will only update when the pipeline is ran for the first time after a change has been made to module.

1.  Clone the customer's Devops Repo on your local machine.Add our Github Arinco Repo as second remote repo:

    ```
    git remote add arincoBicepModules https://github.com/arincoau/arinco-bicep-modules.git
    ```

    You may need to authenticate.

2.  Run the following command to check the remote repositories:

    ```
    git remote -v
    ```

    Two remote repositories should now be available. The origin should be the customer's Devops Repo.

3.  Fetch the content from the Arinco repository:

    ```
    git fetch arincoBicepModules
    ```

    This command fetches all branches from the secondary repository. You can now access these branches locally.

4.  Merge a specific branch from the secondary repository into your current branch. In this case, we merge the main branch of the Arinco Bicep Modules:

    ```
    git merge arincoBicepModules/main
    ```

5.  Confirm that you can now see all the Arinco Modules on the local branch. On line 25 of the refresh-module-table.ps1 table, add the customer's Devops Repo Url (e.g https://dev.azure.com/contoso/Contoso/_git/Contoso-Modules?path=/modules )

6.  Push the local branch to the customer's Devops Repo:

    ```
    git push -u origin --all
    ```

7.  IMPORTANT STEP (DO NOT SKIP): Push the tags to origin:

    ```
    git push origin --tags
    ```

8.  For the pipeline to be able to update the table in README.MD, modify permissions of the build service as shown below.
    Go to Project Setting>Repositories>Security

        ![alt text](image.png)

9.  On line 12 of the publish-module.ps1 file, add the Subscription ID of the Azure Container Registry

---

## After We Update A Module

**Only one module at a time can be updated.**

After a module is updated, navigate to that module’s folder (e.g., `cd ../modules/ai-ml/cognitive-services`) and run `brm generate`.

### Example Scenario

If we update the naming conventions module:

1. Go to the naming conventions module folder in the terminal (i.e., `cd ../modules/naming/conventions`).
2. Run `brm generate`.

When the update is pushed or merged to the main branch, the `on-push-main.yml` pipeline will run and update the `README.md` table.

**The pipeline will fail to run if the following are not adhered to:**

- If you update a module and **do not** run `brm generate`, the pipeline will fail.
- If you update the naming conventions module and then proceed to update the cognitive-services module (i.e., making changes to two modules), the pipeline will fail.
- If the build service does not have the required permissions as stated in Step 8 of the above instructions, the `README.md` table will not update.
