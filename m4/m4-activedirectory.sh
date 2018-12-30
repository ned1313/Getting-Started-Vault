vault write auth/ldap/config \
    url="ldaps://adDC-0.globomantics.xyz" \
    userattr="uid" \
    userdn="ou=Users,dc=example,dc=com" \
    discoverdn=true \
    groupdn="ou=Groups,dc=example,dc=com" \
    certificate=@ldap_ca_cert.pem \
    insecure_tls=false \
    starttls=true