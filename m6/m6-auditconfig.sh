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

#Configuring local file auditing

#Create the directory that vault will write to
sudo mkdir /var/log/vault
sudo chown vault:vault /var/log/vault

vault audit enable file file_path=/var/log/vault/vault_audit.log log_raw=true

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request PUT \
    --data @auditconfig.json $VAULT_ADDR/v1/sys/audit/file1

#For Windows
Invoke-WebRequest -Method Put -Uri $env:VAULT_ADDR/v1/sys/audit/file1 `
 -UseBasicParsing -Headers $headers -Body (get-content auditconfig.json)

#Add another path
vault audit enable -path=file2 file file_path=/var/log/vault/vault_audit2.log

#In Azure, install the OMS Agent from the portal
#Go to the Advanced settings for the Log Analytics portal
#Go to Data\Syslog settings

#On vault server enable the syslog audit device to a facility
vault audit enable syslog tag="vault" facility="LOCAL7"

#Run the following query on Logs
Syslog
| where Facility == "local7" 

#Add some entries to the audit log
vault secrets list
vault kv put secret/audittest secret=mysecret
vault kv get secret/audittest

#View file contents
sudo cat /var/log/vault/vault_audit.log | jq

sudo tail -1 /var/log/vault/vault_audit2.log | jq

sudo tail -1 /var/log/vault/vault_audit2.log | jq -r .response.data.secret

curl --header "X-Vault-Token: $VAULT_TOKEN" --request POST \
 --data '{"input": "mysecret"}' $VAULT_ADDR/v1/sys/audit-hash/file2 | jq -r .data.hash

#Disable original path
vault audit disable file

#Linux
curl --header "X-Vault-Token: $VAULT_TOKEN" --request DELETE \
    $VAULT_ADDR/v1/sys/audit/file1

#For Windows
Invoke-WebRequest -Method Delete -Uri $env:VAULT_ADDR/v1/sys/audit/file1 `
 -UseBasicParsing -Headers $headers



