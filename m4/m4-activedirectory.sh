#Export the Vault server running in AD environment
export VAULT_ADDR=https://vault.globomantics.xyz:8200
export VAULT_TOKEN=AddYourVaultTokenHere

#For Windows
$env:VAULT_ADDR = "https://vault.globomantics.xyz:8200"
$env:VAULT_TOKEN = "AddYourVaultTokenHere"
$headers = @{
    X-Vault-Token = $env:VAULT_TOKEN
}

#Log into Vault server
vault login

#Create a new secrets engine kv path for devs
vault secrets enable -path=devkv kv
vault kv put devkv/alldevs answer=42

#Create a new policy for devs
vault policy write dev devpol.hcl

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request PUT \
 --data @devpol.json $VAULT_ADDR/v1/sys/policies/acl/dev-clone

#For Windows
Invoke-WebRequest -Method Put -Uri $env:VAULT_ADDR/v1/sys/policies/acl/dev-clone `
 -UseBasicParsing -Headers $headers -Body (get-content devpol.json)

#List vault policies
vault read sys/policy

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" \
    $VAULT_ADDR/v1/sys/policy

#For Windows
Invoke-WebRequest -Method Get -Uri $env:VAULT_ADDR/v1/sys/policy `
 -UseBasicParsing -Headers $headers

#Put a secret that devs can't get
vault kv put secret/nodevs mchammer=canttouchthis

#Enable the LDAP auth method
vault auth enable ldap

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data '{"type": "ldap"}' $VAULT_ADDR/v1/sys/auth/ldap

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/sys/auth/ldap `
 -UseBasicParsing -Headers $headers -Body '{"type": "ldap"}'

vault write auth/ldap/config \
    url="ldaps://adDC-0.globomantics.xyz:636" \
    userattr="sAMAccountName" \
    userdn="ou=Globo Users,dc=globomantics,dc=xyz" \
    groupdn="ou=Globo Groups,dc=globomantics,dc=xyz" \
    groupfilter="(&(objectClass=group)(member:1.2.840.113556.1.4.1941:={{.UserDN}}))" \
    binddn="cn=vault-ldap,cn=Users,dc=globomantics,dc=xyz" \
    bindpass='VerySecurePassword@123' \
    groupattr="memberOf" \
    certificate=@globomantics-adDC-0.pem \
    insecure_tls=false \
    starttls=true

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data @ldap-config.json $VAULT_ADDR/v1/auth/ldap/config

#For Windows
Invoke-WebRequest -Method Post -Uri $env:VAULT_ADDR/v1/auth/ldap/config `
 -UseBasicParsing -Headers $headers -Body (Get-Content ldap-config.json)

vault write auth/ldap/groups/developers policies=dev

#Start a second session
vault login -method=ldap username=adent

#Put a new secret in devkv and read the existing one
vault kv put devkv/arthur ford=friend
vault kv get devkv/arthur
vault kv get devkv/alldevs

#Put a new secret in the devkv appId path
vault kv put devkv/appId-123 api-key=123 toast=good
vault kv put devkv/appId-123 api-key=123 environment=toast
vault kv put devkv/appId-123 api-key=123 environment=qa description="secret for appId 123"

#Can't write to secret kv in general
vault kv put secret/arthur dolphins=solong
#Try to read a secret outside the devkv path
vault kv get secret/nodevs

#Get Arthur's entity ID
vault token lookup
vault kv put secret/ENTITYID/friends best=ford

#Try to enumerate the secrets engines
vault secrets list
