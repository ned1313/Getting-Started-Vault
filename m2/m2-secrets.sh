################# Installing Vault ##########################

#For Windows
$vaultVersion = "1.0.1"
Invoke-WebRequest -Uri https://releases.hashicorp.com/vault/$vaultVersion/vault_$($vaultVersion)_windows_amd64.zip -OutFile .\vault_$($vaultVersion)_windows_amd64.zip
Expand-Archive .\vault_$($vaultVersion)_windows_amd64.zip
cd .\vault_$($vaultVersion)_windows_amd64
#Copy vault executable to a location include in your path variable

#For Linux
VAULT_VERSION="1.0.1"
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip

#Install unzip if necessary
sudo apt install unzip -y
unzip vault_${VAULT_VERSION}_linux_amd64.zip
sudo chown root:root vault
sudo mv vault /usr/local/bin/

################# Starting the Dev server ######################

#Start the Dev server for vault
vault server -dev 

#Set env variable
#For Linux/MacOS
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=AddYourVaultTokenHere

#For Windows
$env:VAULT_ADDR = "http://127.0.0.1:8200"
$env:VAULT_TOKEN = "AddYourVaultTokenHere"
$headers = @{
    "X-Vault-Token" = $env:VAULT_TOKEN
}

#Log into the vault server
#Use the root token from the output
vault login

############## Basic Secret Commands for KV ######################

#Write a secret
vault kv put secret/hg2g answer=42
#For Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data @marvin.json $VAULT_ADDR/v1/secret/data/marvin
#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/secret/data/marvin `
 -UseBasicParsing -Headers $headers -Body (get-content marvin.json)

#Get a secret
vault kv get secret/hg2g

#For Linux
#Install jq if necessary
sudo apt install jq -y
curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/secret/data/marvin | jq

#For Windows
Invoke-WebRequest -Method Get -Uri $env:VAULT_ADDR/v1/secret/data/marvin `
 -UseBasicParsing -Headers $headers

#Put a new secret in and a new value for an existing secret
vault kv put secret/hg2g answer=54 ford=prefect
vault kv get secret/hg2g

#Delete the secrets
vault kv delete secret/hg2g
vault kv get secret/hg2g

#For Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request DELETE $VAULT_ADDR/v1/secret/data/marvin

#For Windows
Invoke-WebRequest -Method Delete -Uri $env:VAULT_ADDR/v1/secret/data/marvin `
 -UseBasicParsing -Headers $headers



