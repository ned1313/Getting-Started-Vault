#Install Vault
VAULT_VERSION="1.0.0"
wget https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip
unzip vault_${VAULT_VERSION}_linux_amd64.zip
sudo chown root:root vault
sudo mv vault /usr/local/bin/

#Prepare for systemd
sudo useradd --system --home /etc/vault.d --shell /bin/false vault
sudo mkdir --parents /opt/vault
sudo chown --recursive vault:vault /opt/vault

sudo touch /etc/systemd/system/vault.service

#Create general config
sudo mkdir --parents /etc/vault
sudo touch /etc/vault/vault_server.hcl
sudo chown --recursive vault:vault /etc/vault
sudo chmod 640 /etc/vault/vault_server.hcl

#Create certs (main server only - self-signed only)
sudo mkdir /etc/vault/certs
sudo openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out /etc/vault/certs/vault_cert.crt -keyout /etc/vault/certs/vault_cert.key
sudo chown --recursive vault:vault /etc/vault/certs
sudo chmod 750 --recursive /etc/vault/certs/

#Start service
sudo systemctl enable vault
sudo systemctl start vault

#Adding certificates
sudo mkdir /etc/vault/certs
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt-get update
sudo apt-get install certbot -y
sudo certbot certonly --standalone --email ned@nedinthecloud.com -d vault.globomantics.xyz --agree-tos
sudo cp /etc/letsencrypt/live/vault.globomantics.xyz/fullchain.pem /etc/vault/certs/vault_cert.crt
sudo cp /etc/letsencrypt/live/vault.globomantics.xyz/privkey.pem /etc/vault/certs/vault_cert.key
sudo chown --recursive vault:vault /etc/vault/certs
sudo chmod 750 --recursive /etc/vault/certs/

#Add entry to hosts
sudo vi /etc/hosts

#Set environment variable for vault server
export VAULT_ADDR=https://server:8200

#Install auditd and the Log Analytics agent
sudo mkdir /var/log/vault
sudo chown vault:vault /var/log/vault
vault audit enable file file_path=/var/log/vault/vault_audit.log
