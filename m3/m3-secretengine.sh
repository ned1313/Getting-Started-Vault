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

#Enable a new secrets engine path
vault secrets enable -path=dev-a kv

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data @dev-b.json $VAULT_ADDR/v1/sys/mounts/dev-b
#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/sys/mounts/dev-b `
 -UseBasicParsing -Headers $headers -Body (get-content dev-b.json)

#View the secrets engine paths
vault secrets list

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/sys/mounts

#For Windows
Invoke-WebRequest -Method Get -Uri $env:VAULT_ADDR/v1/sys/mounts `
 -UseBasicParsing -Headers $headers

#Add secrets to the new secrets engine path
vault kv put dev-a/arthur love=trillian friend=ford
vault kv get dev-a/arthur

#Alternate command
vault write dev-a/arthur enemy=zaphod
vault read dev-a/arthur

#Move the secrets engine path
vault secrets move dev-a dev-a-moved

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data @dev-b-moved.json $VAULT_ADDR/v1/sys/remount

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/sys/remount `
 -UseBasicParsing -Headers $headers -Body (get-content dev-b-moved.json)

vault secrets list
vault read dev-a-moved/arthur

#Upgrade the secrets engine to v2
vault kv enable-versioning dev-a-moved

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data @dev-b-moved-v2.json $VAULT_ADDR/v1/sys/mounts/dev-b-moved/tune

curl --header "X-Vault-Token: $VAULT_TOKEN" $VAULT_ADDR/v1/sys/mounts/dev-b-moved/tune

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/sys/mounts/dev-b-moved/tune `
 -UseBasicParsing -Headers $headers -Body (get-content dev-b-moved-v2.json)

Invoke-WebRequest -Method Get -Uri $env:VAULT_ADDR/v1/sys/mounts/dev-b-moved/tune `
 -UseBasicParsing -Headers $headers

#Create a new secrets engine on v2
vault secrets enable -path=dev-c -version=2 kv 

#Disable the secrets engine
vault secrets disable dev-a

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request DELETE \
 $VAULT_ADDR/v1/sys/mounts/dev-b-moved

#For Windows
Invoke-WebRequest -Method Delete -Uri $env:VAULT_ADDR/v1/sys/mounts/dev-b-moved `
 -UseBasicParsing -Headers $headers

vault secrets list



