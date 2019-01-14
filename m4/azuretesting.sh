export VAULT_ADDR=https://vault.globomantics.xyz:8200

metadata=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-08-01")

subscription_id=$(echo $metadata | jq -r .compute.subscriptionId)
vm_name=$(echo $metadata | jq -r .compute.name)
resource_group_name=$(echo $metadata | jq -r .compute.resourceGroupName)

response=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fmanagement.azure.com%2F' -H Metadata:true -s)

jwt=$(echo $response | jq -r .access_token)

sed -i "s/ROLE_NAME_STRING/web-role/g" auth_payload_complete.json
sed -i "s/JWT_STRING/$jwt/g" auth_payload_complete.json
sed -i "s/SUBSCRIPTION_ID_STRING/$subscription_id/g" auth_payload_complete.json
sed -i "s/RESOURCE_GROUP_NAME_STRING/$resource_group_name/g" auth_payload_complete.json
sed -i "s/VM_NAME_STRING/$vm_name/g" auth_payload_complete.json

login=$(curl --request POST --data @auth_payload_complete.json $VAULT_ADDR/v1/auth/azure/login)

export VAULT_TOKEN=$(echo $login | jq -r .auth.client_token)

curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/webkv/webpass