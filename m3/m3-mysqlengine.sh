#Set env variable
#For Linux/MacOS
export VAULT_ADDR=http://127.0.0.1:8200
#For Windows
$env:VAULT_ADDR = "http://127.0.0.1:8200"

#Enable the database secrets engine
vault secrets enable database

#Change <YourPublicIP> to your public IP address

#Configure MySQL roles and permissions
mysql -u root -p
CREATE ROLE 'dev-role';
CREATE USER 'vault'@'<YourPublicIP>' IDENTIFIED BY 'AsYcUdOP426i';
CREATE DATABASE devdb;
GRANT ALL ON *.* TO 'vault'@'<YourPublicIP>';
GRANT GRANT OPTION ON devdb.* TO 'vault'@'<YourPublicIP>';

#Change <MYSQL_IP> to the IP address of the MySQL server
#Configure the MySQL plugin
vault write database/config/dev-mysql-database \
    plugin_name=mysql-database-plugin \
    connection_url="{{username}}:{{password}}@tcp(<MYSQL_IP>:3306)/" \
    allowed_roles="dev-role" \
    username="vault" \
    password="AsYcUdOP426i"

vault write database/roles/dev-role \
    db_name=dev-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON devdb.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

vault read database/creds/dev-role