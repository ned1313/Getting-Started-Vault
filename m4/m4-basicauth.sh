################# Starting the Dev server ######################
## Skip this part if you've already done module 3 and left the
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

#List the current auth methods
vault auth list

#Enable userpass auth method
vault auth enable userpass

#Explore the userpass auth method
vault path-help auth/userpass

#Add a user to the userpass auth method
vault write auth/userpass/users/arthur password=dent

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data @ford.json $VAULT_ADDR/v1/auth/userpass/users/ford

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/auth/userpass/users/ford `
 -UseBasicParsing -Headers $headers -Body (get-content ford.json)

vault list auth/userpass/users

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request LIST \
 $VAULT_ADDR/v1/auth/userpass/users

#For Windows
Invoke-WebRequest -Method List -Uri $env:VAULT_ADDR/v1/auth/userpass/users `
 -UseBasicParsing -Headers $headers

#Start a second session
vault login -method=userpass username=arthur

vault token lookup

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data '{"username": "ford", "password": "prefect"}' $VAULT_ADDR/v1/auth/userpass/login/ford

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/auth/userpass/login/ford `
 -UseBasicParsing -Headers $headers -Body '{"username": "ford", "password": "prefect"}'

#Reset password
vault write auth/userpass/users/arthur/password password=tricia

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data '{"password": "zaphod"}' $VAULT_ADDR/v1/auth/userpass/users/ford

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/auth/userpass/users/ford `
 -UseBasicParsing -Headers $headers -Body '{"password": "zaphod"}'

#Remove account
vault delete auth/userpass/users/arthur

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request DELETE \
 $VAULT_ADDR/v1/auth/userpass/users/ford

#For Windows
Invoke-WebRequest -Method Delete -Uri $env:VAULT_ADDR/v1/auth/userpass/users/ford `
 -UseBasicParsing -Headers $headers

