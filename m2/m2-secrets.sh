#Install vault
#For Windows
$vaultVersion = "1.0.1"
Invoke-WebRequest -Uri 

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
    X-Vault-Token = $env:VAULT_TOKEN
}
#Log into the vault server
#Use the root token from the output
vault login

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
curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/secret/data/marvin | jq

#For Windows
Invoke-WebRequest -Method Get -Uri $env:VAULT_ADDR/v1/secret/data/marvin `
 -UseBasicParsing -Headers $headers

#Get it in JSON
vault kv get -format=json secret/hg2g

#Parse the output using jq
vault kv get -format=json secret/hg2g | jq -r .data.data.answer

#Put a new secret in and a new value for an existing secret
vault kv put secret/hg2g answer=54 ford=prefect

#Get all the secrets in the path
vault kv get secret/hg2g

#Get all the version 1 secrets and version 2
vault kv get -version=1 secret/hg2g
vault kv get -version=2 secret/hg2g

#Delete the secrets
vault kv delete secret/hg2g

