# Readme

![This is an image](https://www.inthecloud247.com/wp-content/uploads/2022/01/Azure-Logic-Apps-GitHub01.png)

## First version

The original solution provided by [Peter Klapwijk](https://twitter.com/inthecloud_247) needs an Azure Active Directory App registration (with a secret) and contains

* a Logic App
* a KeyVault (to store the secret)

You can manually deploy this first version like this: [How to manually deploy first version](README.md#instructions-for-manually-deploying-the-first-version)

## Instructions for manually deploying the first version

1. Download the azuredeploy.json file
2. Sign in to https://portal.azure.com
3. Search for Deploy a custom template
4. Click build your own template in the editor
5. Click Load file and select azuredeploy.
6. Click Save
7. Select a Resource group
8. Enter the Key vault name and webhook-uri
9. Click Review + create
10. Click Create
11. Search for Logic Apps
12. Open the Logic App
13. Browse to Api connections, Edit connection
14. Click Authorize
15. Sign in
16. Click Save
17. Done!

For more information and the **requirements** for this Logic Apps flow read the related [Blog Post](https://www.inthecloud247.com/get-your-windows-autopilot-deployment-events-in-a-teams-channel-with-logic-apps/)

## Second version

The second version provided by [Luise Freese](https://twitter.com/LuiseFreese)

* handles authentication with an [Azure Managed Identity](https://docs.microsoft.com/azure/active-directory/managed-identities-azure-resources/overview) - (read if you don't know what is a managed identity - it's worth to know!)
* does not need an Azure Active Directory App registration anymore (which means no secret!)
* does not to have a Key Vault (as we don't need to protect a secret)

You can automatically deploy this version like this [How to automatically deploy second version](README.md#instructions-for-automatically-deploying-second-version)

## Instructions for automatically deploying second version

1. Fork this repository
2. Open [Azure cloud shell](https://shell.azure.com)
3. Clone the repository in cloud shell
4. Navigate to the `Receive Windows Autopilot deployment events in Teams` folder
5. Run `.\deploy.ps1` - this script
    * will ask you to provide
        * the name of the Resource group
        * an Azure region (In case you don't know which regions are available, please run `az account list-locations -o table`)
        * the name of the Managed Identity you want to create
        * the Azure region

        where you want your resources to be deployed
    * will deploy
        * the resource group
        * the Logic App
        * the user-assigned Managed Identity

Lastly, the `DeviceManagementManagedDevices.Read.All` and `DeviceManagementServiceConfig.Read.All` permissions of Microsoft Graph API will be assigned to the Managed Identity

Now let's make the connection work:

1. Log into the [Azure portal](https://portal.azure.com)
2. Select the resource group that you created by running the script
3. Navigate to the Logic App
7. Add the webhook URI in the Logic App to meet your needs.

You can read more about this approach on Luise's blog: [Get rid of Key Vault! Making good things even better](https://www.m365princess.com/blogs/rid-key-vault-making-good/)
