#Consul Build commands

#Install Consul
sudo apt update -y
sudo apt install unzip -y
CONSUL_VERSION="1.4.1"
wget https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip
unzip consul_${CONSUL_VERSION}_linux_amd64.zip
sudo chown root:root consul
sudo mv consul /usr/local/bin/

#Prepare for systemd
sudo useradd --system --home /etc/consul.d --shell /bin/false consul
sudo mkdir --parents /opt/consul
sudo chown --recursive consul:consul /opt/consul

sudo touch /etc/systemd/system/consul.service

#Create general config
ip addr
sudo mkdir --parents /etc/consul.d
sudo touch /etc/consul.d/consul.hcl
sudo chown --recursive consul:consul /etc/consul.d
sudo chmod 640 /etc/consul.d/consul.hcl

#Start service
sudo systemctl enable consul
sudo systemctl start consul

#Check consul status
consul members
