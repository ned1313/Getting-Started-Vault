#Powershell users
#Install the Azure CLI
choco install azure-cli -y


#Linux users
#Install Azure CLI per your distro
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

#Set up variables
# WINDOWS
$AZURE_SUBSCRIPTION_ID = Read-Host -Prompt "Enter Azure Subscription ID"
$AZURE_TENANT_ID  = Read-Host -Prompt "Enter Azure Tenant ID"

# LINUX
export AZURE_SUBSCRIPTION_ID=""
export AZURE_TENANT_ID=""

#Login into Azure CLI
az login 

#Create an Service Principal and grant owner rights on the subscription
az ad sp create-for-rbac --name vaultsp --role owner --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID


$AZURE_CLIENT_ID  = Read-Host -Prompt "Enter Azure Client (Application) ID"
$AZURE_CLIENT_SECRET = Read-Host -Prompt "Enter Azure Client secret (Password)"

#Set the variables

export AZURE_CLIENT_ID=""
export AZURE_CLIENT_SECRET=""

#Enable the Azure secrets engine and configure it
vault secrets enable azure
vault write azure/config subscription_id=$AZURE_SUBSCRIPTION_ID tenant_id=$AZURE_TENANT_ID client_id=$AZURE_CLIENT_ID client_secret=$AZURE_CLIENT_SECRET

#Login into Azure CLI
az login 

#Create a new resource group
az group create --name vault_test_group --location eastus

#Create a new role using the vault secrets engine
# For PowerShell run the following
$role_info = get-content azure-role.json
$role_info.replace("<uuid>",$AZURE_SUBSCRIPTION_ID) | Set-Content -Path .\azure-role.json

#In Linux do the following
sed -i 's/<uuid>/$AZURE_SUBSCRIPTION_ID/g' azure-role.json

#Add the role to vault
vault write azure/roles/my-role ttl=1h azure_roles=@azure-role.json
vault read azure/roles/my-role

#Get a credential using that role
vault read azure/creds/my-role
