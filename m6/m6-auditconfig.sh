#Configuring local file auditing

#Create the directory that vault will write to
sudo mkdir /var/log/vault
sudo chown vault:vault /var/log/vault

vault audit enable file file_path=/var/log/vault/vault_audit.log log_raw=true

#Add another path
vault audit enable -path=file2 file_path=/opt/vault/vault_audit2.log

#Disable original path
vault audit disable file

#In Azure, install the OMS Agent from the portal
#Go to the Advanced settings for the Log Analytics portal
#Go to Data\Syslog settings

#On vault server enable the syslog audit device to a facility
vault audit enable syslog tag="vault" facility="LOCAL7"

#Run the following query on Logs
Syslog
| where Facility == "local7" 
