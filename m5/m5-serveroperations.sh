#Set env variable
#For Linux/MacOS
export VAULT_ADDR=https://vault-1.globomantics.xyz:8200
export VAULT_TOKEN=AddYourVaultTokenHere

#For Windows
$env:VAULT_ADDR = "https://vault-1.globomantics.xyz:8200"
$env:VAULT_TOKEN = "AddYourVaultTokenHere"
$headers = @{
    "X-Vault-Token" = $env:VAULT_TOKEN
}

#Initialize the new vault server
vault operator init -status
vault operator init

#Check status
vault status

#Unseal vault server
vault operator unseal

#Linux
curl --request PUT \
 --data '{"key": "SHARE_KEY"}' $VAULT_ADDR/v1/sys/unseal | jq

#For Windows
Invoke-WebRequest -Method Put -Uri $env:VAULT_ADDR/v1/sys/unseal `
 -UseBasicParsing -Body '{"key": "SHARE_KEY"}'

#login into vault server
vault login

#Rotate the encryption key
vault operator key-status
vault operator rotate

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request PUT \
 $VAULT_ADDR/v1/sys/rotate

#For Windows
Invoke-WebRequest -Method Put -Uri $env:VAULT_ADDR/v1/sys/rotate `
 -UseBasicParsing -Headers $headers

#Rekey the vault seal
vault operator rekey -init -key-shares=3 -key-threshold=2

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request PUT \
 --data '{"secret_shares": 5, "secret_threshold": 2}' $VAULT_ADDR/v1/sys/rekey/init | jq

#For Windows
Invoke-WebRequest -Method Put -Uri $env:VAULT_ADDR/v1/sys/rekey/init `
 -UseBasicParsing -Headers $headers -Body '{"secret_shares": 5, "secret_threshold": 2}'

vault operator rekey -status
vault operator rekey

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request PUT \
 --data '{"key": "SHARE_KEY", "nonce": "NONCE"}' $VAULT_ADDR/v1/sys/rekey/update | jq

#For Windows
Invoke-WebRequest -Method Put -Uri $env:VAULT_ADDR/v1/sys/rekey/update `
 -UseBasicParsing -Headers $headers -Body '{"key": "SHARE_KEY", "nonce": "NONCE"}'

#Rotate the root key
vault operator generate-root -generate-otp

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request PUT \
 $VAULT_ADDR/v1/sys/generate-root/attempt | jq

#For Windows
Invoke-WebRequest -Method Put -Uri $env:VAULT_ADDR/v1/sys/generate-root/attempt `
 -UseBasicParsing -Headers $headers

vault operator generate-root -init -otp="OTP_TOKEN"
vault operator generate-root

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request PUT \
 --data '{"key": "SHARE_KEY", "nonce": "NONCE"}' $VAULT_ADDR/v1/sys/generate-root/update | jq

#For Windows
Invoke-WebRequest -Method Put -Uri $env:VAULT_ADDR/v1/sys/generate-root/update `
 -UseBasicParsing -Headers $headers -Body '{"key": "SHARE_KEY", "nonce": "NONCE"}'

vault operator generate-root -decode="DECODE_TOKEN" -otp="OTP_TOKEN"

#No equivalent operation in API, need to decode base64 string and XOR with OTP

#Login with new root token
vault login

#Revoke the old root token
vault token revoke ROOT_TOKEN

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data '{"token": "OLD_TOKEN"}' $VAULT_ADDR/v1/auth/token/revoke

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/auth/token/revoke `
 -UseBasicParsing -Headers $headers -Body '{"token": "OLD_TOKEN"}'

#Seal the vault for maintenance
vault operator seal

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request PUT \
 $VAULT_ADDR/v1/sys/seal

#For Windows
Invoke-WebRequest -Method Put -Uri $env:VAULT_ADDR/v1/sys/seal `
 -UseBasicParsing -Headers $headers

vault status

