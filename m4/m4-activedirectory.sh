#Create a new secrets engine kv path for devs
vault secrets enable -path=devkv kv

#Create a new policy for devs
vault policy write dev devpol.hcl

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

vault write auth/ldap/groups/developers policies=dev