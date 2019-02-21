# LINUX
az account show --subscription MAS

export AZURE_SUBSCRIPTION_ID=""
export AZURE_TENANT_ID=""

#Create an Service Principal and grant owner rights on the subscription
az ad sp create-for-rbac --name http://vault-hugs --role contributor --scopes /subscriptions/SUB_ID

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
vault kv put webkv/webpass password=hugs-for-all

#Create a web policy
vault policy write web webpol.hcl

#Create role
vault write auth/azure/role/web-role \
    policies="web" \
    bound_subscription_ids=$AZURE_SUBSCRIPTION_ID \
    bound_resource_groups=HashiTalks

#On web server
sudo apt update
sudo apt install nginx jq -y
sudo ufw allow 'Nginx HTTP'
export VAULT_ADDR=https://vault.azslab.us:8200

metadata=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01")

subscription_id=$(echo $metadata | jq -r .compute.subscriptionId)
vm_name=$(echo $metadata | jq -r .compute.name)
resource_group_name=$(echo $metadata | jq -r .compute.resourceGroupName)

response=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true -s)

jwt=$(echo $response | jq -r .access_token)

cp auth_payload.json auth_payload_complete.json

sed -i "s/ROLE_NAME_STRING/web-role/g" auth_payload_complete.json
sed -i "s/JWT_STRING/$jwt/g" auth_payload_complete.json
sed -i "s/SUBSCRIPTION_ID_STRING/$subscription_id/g" auth_payload_complete.json
sed -i "s/RESOURCE_GROUP_NAME_STRING/$resource_group_name/g" auth_payload_complete.json
sed -i "s/VM_NAME_STRING/$vm_name/g" auth_payload_complete.json

login=$(curl --request POST --data @auth_payload_complete.json $VAULT_ADDR/v1/auth/azure/login)

export VAULT_TOKEN=$(echo $login | jq -r .auth.client_token)

webpass=$(curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/webkv/webpass | jq -r .data.password)

cat <<EOM >~/index.html
<html>
    <head>
        <title>Welcome to HashiTalks!</title>
    </head>
    <body>
        <h1>The secret passphrase is: $webpass</h1>
    </body>
</html>
EOM

sudo cp ~/index.html /var/www/html/index.html
sudo systemctl restart nginx