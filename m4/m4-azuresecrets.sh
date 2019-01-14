#Powershell users
#Install the Azure CLI
choco install azure-cli -y


#Linux users
#Install Azure CLI per your distro
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

#Set up variables

# LINUX
export AZURE_SUBSCRIPTION_ID="4d8e572a-3214-40e9-a26f-8f71ecd24e0d"
export AZURE_TENANT_ID="f06624a8-558d-45ab-8a87-a88094a3995d"

#Login into Azure CLI
az login 

#Create an Service Principal and grant owner rights on the subscription
az ad sp create-for-rbac --name http://vaultsp --role owner --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID

#Set the variables
export AZURE_CLIENT_ID="ec79de6e-9c73-44b3-8801-f652540101ed"
export AZURE_CLIENT_SECRET="ca1605fd-fce8-4bec-9065-20509e08fcc4"

#Enable the Azure secrets engine and configure it
vault secrets enable azure

vault write azure/config \
  subscription_id=$AZURE_SUBSCRIPTION_ID \
  tenant_id=$AZURE_TENANT_ID \
  client_id=$AZURE_CLIENT_ID \
  client_secret=$AZURE_CLIENT_SECRET

#Login into Azure CLI
az login 

#Create a new resource group
az group create --name vault_test_group --location eastus

#Create a new role using the vault secrets engine
#In Linux do the following
sed -i 's/<uuid>/$AZURE_SUBSCRIPTION_ID/g' azure-role.json

#Add the role to vault
vault write azure/roles/my-role ttl=1h azure_roles=@azure-role.json
vault read azure/roles/my-role

#Get a credential using that role
vault read azure/creds/my-role

#Now enable the Azure auth method
vault auth enable azure

#Configure the Azure auth method
vault write auth/azure/config \
    tenant_id=$AZURE_TENANT_ID \
    resource=https://management.azure.com/ \
    client_id=$AZURE_CLIENT_ID \
    client_secret=$AZURE_CLIENT_SECRET

#Create a web kv store
vault secrets enable -path=webkv kv
vault kv put webkv/webpass password=marvin

#Create a web policy
vault policy write web webpol.hcl

#Create role
vault write auth/azure/role/web-role \
    policies="web" \
    bound_subscription_ids=$AZURE_SUBSCRIPTION_ID \
    bound_resource_groups=vault

#On web server
sudo apt install jq -y
 curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true -s
 curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01" | jq