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
    X-Vault-Token = $env:VAULT_TOKEN
}

#Log into the vault server
#Use the root token from the output
vault login

############## Advanced Secret Commands for KV ####################
## Skip this part if you've already done module 2 and left the
## Dev server running

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

#Delete the secrets
vault kv delete secret/hg2g
vault kv get secret/hg2g

#Destroy the secrets
vault kv destroy -versions=1,2 secret/hg2g
vault kv get secret/hg2g

#For Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST $VAULT_ADDR/v1/secret/destroy/marvin --data '{"versions": [1]}'

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/secret/destroy/marvin `
 -UseBasicParsing -Headers $headers -Body '{"versions": [1]}'

#Remove all data about secrets
vault kv metadata delete secret/hg2g

####################### Adding a Secrets Engine ###########################
#Enable a new secrets engine path
vault secrets enable -path=arthur kv

#View the secrets engine paths
vault secrets list
vault secrets list -format=json

#Add secrets to the new secrets engine path
vault kv put arthur/dent love=trillian friend=ford
vault kv get arthur/dent

#Alternate command
vault write arthur/dent enemy=zaphod
vault read arthur/dent

#Move the secrets engine path
vault secrets move arthur zaphod
vault secrets list
vault list zaphod
vault read zaphod/dent

#Upgrade the secrets engine to v2
vault kv enable-versioning zaphod

#Create a new secrets engine on v2
vault secrets enable -path=android -version=2 kv 

#Disable the secrets engine
vault secrets disable zaphod
vault secrets disable android
vault secrets list



