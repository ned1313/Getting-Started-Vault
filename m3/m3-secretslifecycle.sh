################# Starting the Dev server ######################
## Skip this part if you've already done module 2 and left the
## Dev server running

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

############## Advanced Secret Commands for KV ####################

#Write a secret
vault kv put secret/hg2g answer=42
#Put a new secret in and a new value for an existing secret
vault kv put secret/hg2g answer=54 ford=prefect

#Get it in JSON
vault kv get -format=json secret/hg2g

#Parse the output using jq
vault kv get -format=json secret/hg2g | jq -r .data.data.answer

#Get all the secrets in the path
vault kv get secret/hg2g

#Get all the version 1 secrets and version 2
vault kv get -version=1 secret/hg2g
vault kv get -version=2 secret/hg2g

#For Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/secret/data/hg2g?version=1 | jq .data.data

#For Windows
Invoke-WebRequest -Method Get -Uri $env:VAULT_ADDR/v1/secret/data/hg2g?version=1 `
 -UseBasicParsing -Headers $headers

#Delete a secrets
vault kv delete secret/hg2g
vault kv get secret/hg2g

#For Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request DELETE \
  $VAULT_ADDR/v1/secret/data/hg2g

#For Windows
Invoke-WebRequest -Method Delete -Uri $env:VAULT_ADDR/v1/secret/data/hg2g `
 -UseBasicParsing -Headers $headers 

vault kv get -version=1 secret/hg2g

#Undelete a secret
vault kv undelete -versions=2 secret/hg2g

#For Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  $VAULT_ADDR/v1/secret/undelete/hg2g  --data '{"versions": [2]}'

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/secret/undelete/hg2g `
 -UseBasicParsing -Headers $headers -Body '{"versions": [2]}'

vault kv get secret/hg2g

#Destroy the secrets
vault kv destroy -versions=1,2 secret/hg2g
vault kv get secret/hg2g

#For Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
  $VAULT_ADDR/v1/secret/destroy/hg2g --data '{"versions": [1,2]}'

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/secret/destroy/hg2g `
 -UseBasicParsing -Headers $headers -Body '{"versions": [1,2]}'

#Remove all data about secrets
vault kv metadata delete secret/hg2g
vault kv get secret/hg2g

#For Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request DELETE \
  $VAULT_ADDR/v1/secret/metadata/hg2g

#For Windows
Invoke-WebRequest -Method Delete -Uri $env:VAULT_ADDR/v1/secret/metadata/hg2g `
 -UseBasicParsing -Headers $headers