#Start the Dev server for vault
vault server -dev 

#Set env variable
#For Linux/MacOS
export VAULT_ADDR=http://127.0.0.1:8200
#For Windows
$env:VAULT_ADDR = "http://127.0.0.1:8200"

#Enable a new secrets engine path
vault secrets enable -path=arthur kv

#View the secrets engine paths
vault secrets list

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

#Disable the secrets engine
vault secrets disable zaphod
vault secrets list



