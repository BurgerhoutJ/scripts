#Variables
RG=CATPRDEUWGHOST1RG
WEBAPPNAME=appcatghostblogtest
LOCATION=WestEurope
APPSERVICE=aspcatprdeuwghost
SQLUSER=admin_$RANDOM
SQLPASS="ZkdFR.Ju4/<}&;PJ*@RDq5.?4BLH]T"
SQLSERVERNAME=sqlserver$RANDOM
PLAN=B1
SANAME=sacatghosttest
FILESHARE=sharecatghostfiles
SQLSKU=B_Gen5_1

#Resource group
echo "Creating resource group"
az group create --name $RG --location $LOCATION

#Storage Account
echo "Creating storage account, fileshare and retrieving accesskey"
az storage account create --resource-group $RG  --name $SANAME --access-tier Cool --location $LOCATION --sku Standard_LRS
az storage share create --account-name $SANAME --name $FILESHARE
SAKEY=$(az storage account keys list -g $RG -n $SANAME --query [0].value -o tsv)

#MySQL Server
echo "Spinning up MySQL $SQLSERVERNAME in group $RG Admin is $SQLUSER"
az mysql server create --resource-group $RG --location $LOCATION --name $SQLSERVERNAME --admin-user $SQLUSER --admin-password $SQLPASS --sku-name $SQLSKU --ssl-enforcement Disabled --storage-size 5120 --auto-grow Enabled

#Checking your IP
echo "Guessing your external IP address from ipinfo.io"
IP=$(curl -s ipinfo.io/ip)
echo "Your IP is $IP"

# Create firewall rules, so we can access the MySQL server
echo "Popping a hole in firewall for IP address $IP (that's you)"
az mysql server firewall-rule create --resource-group $RG --server $SQLSERVERNAME --name MyHomeIP --start-ip-address $IP --end-ip-address $IP

# Open up the firewall so wordpress can access - this is internal IP only
echo "Popping a hole in firewall for Azure services"
az mysql server firewall-rule create --resource-group $RG --server $SQLSERVERNAME --name AllowAzureIP --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

#Create the database
echo "Creating Ghost Database"
mysql --host=$SQLSERVERNAME.mysql.database.azure.com \
      --user=$SQLUSER@$SQLSERVERNAME --password=$SQLPASS \
      -e 'create database ghost;' mysql

#Set ENV variables
echo "Setting ENV variables locally"
MYSQL_SERVER=$SQLSERVERNAME.mysql.database.azure.com
MYSQL_USER=$SQLUSER@$SQLSERVERNAME
MYSQL_PASSWORD=$SQLPASS
MYSQL_PORT=3306

#Create the AppService plan
echo "Creating AppService Plan"
az appservice plan create --name $APPSERVICE --resource-group $RG --sku $PLAN --is-linux

#Creating the web app
echo "Creating Web app"
az webapp create --resource-group $RG --plan $APPSERVICE --name $WEBAPPNAME --deployment-container-image-name ghost

#Stop the webapp
az webapp stop --name $WEBAPPNAME --resource-group $RG

#Adding some functional settings to it
echo "Adding app settings"
az webapp config appsettings set --name $WEBAPPNAME \
                                 --resource-group $RG \
                                 --settings \
                                 database__client=mysql \
                                 database__connection__database=ghost \
                                 database__connection__host=$MYSQL_SERVER \
                                 database__connection__user=$MYSQL_USER \
                                 database__connection__password=$MYSQL_PASSWORD \
                                 WEBSITES_PORT=2368 \
                                 WEBSITES_ENABLE_APP_SERVICE_STORAGE=true \
                                 NODE_ENV=production \
                                 url=http://$WEBAPPNAME.azurewebsites.net \
                                 paths__contentPath=/var/lib/ghost/content_files

#Turn on Always-on and disable FTPS
echo "Doing something with general settings"
az webapp config set --name $WEBAPPNAME \
                     --resource-group $RG \
                     --always-on true \
                     --ftps-state Disabled                                 

#Configure path mappings
echo "Add some persistant storage to the webapp"
az webapp config storage-account add --resource-group $RG --name $WEBAPPNAME \
                                --account-name $SANAME \
                                --custom-id catghostsharetest \
                                --share-name $FILESHARE \
                                --access-key $SAKEY \
                                --storage-type AzureFiles \
                                --mount-path /var/lib/ghost/content_files
            
#Start the webapp
az webapp start --name $WEBAPPNAME --resource-group $RG

#All done. Opening the site admin to create a account and personalize it.
echo "Opening site admin. This might give a 502. Just wait for an extra minute."
echo "When it does start, head to https://$WEBAPPNAME.azurewebsites.net/ghost to set it up."