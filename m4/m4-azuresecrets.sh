# LINUX
export AZURE_SUBSCRIPTION_ID=""
export AZURE_TENANT_ID=""

#Create an Service Principal and grant owner rights on the subscription
az ad sp create-for-rbac --name http://vaultsp --role owner --scopes /subscriptions/$AZURE_SUBSCRIPTION_ID

#Set the variables
export AZURE_CLIENT_ID=""
export AZURE_CLIENT_SECRET=""

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