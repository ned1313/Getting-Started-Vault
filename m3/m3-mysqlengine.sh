################# Setting environment variables ######################
#Skip if you've already done this in the current session
#Set env variable
#For Linux/MacOS
export VAULT_ADDR=http://127.0.0.1:8200
#For Windows
$env:VAULT_ADDR = "http://127.0.0.1:8200"

################# Enable database secrets engine ######################
#You are going to need an instance of MySQL running somewhere.  I use
#the Bitnami image on Azure, but you could do it locally instead.  You
#will need to open port 3306 on the remote instance to let Vault talk
#to it properly

#Enable the database secrets engine
vault secrets enable database

#Change <YourPublicIP> to your public IP address if you're using a remote
#MySQL instance

#SSH into the MySQL instance and run the follow commands.

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
    connection_url="{{username}}:{{password}}@tcp(MY_SQL_IP:3306)/" \
    allowed_roles="dev-role" \
    username="vault" \
    password="AsYcUdOP426i"

#Configure a role to be used
vault write database/roles/dev-role \
    db_name=dev-mysql-database \
    creation_statements="CREATE USER '{{name}}'@'%' IDENTIFIED BY '{{password}}';GRANT ALL ON devdb.* TO '{{name}}'@'%';" \
    default_ttl="1h" \
    max_ttl="24h"

#Generate credentials on the DB from the role
vault read database/creds/dev-role

#Validate that the user has been created on MySQL and that the proper
#permissions have been applied
SELECT User FROM mysql.user;
SHOW GRANTS FOR 'username';

#Renew the lease
vault lease renew -increment=3600 database/creds/dev-role/LEASE_ID

vault lease renew -increment=96400 database/creds/dev-role/LEASE_ID

#Revoke the lease
vault lease revoke database/creds/dev-role/LEASE_ID

