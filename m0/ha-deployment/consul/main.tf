##################################################################################
# PROVIDERS
##################################################################################

provider "azurerm" {
  subscription_id = "${var.az_subscription}"
  client_id = "${var.az_client_id}"
  client_secret     = "${var.az_client_secret}"
  tenant_id = "${var.az_tenant_id}"
}

###################################################################################
# DATA
###################################################################################

locals {
  node_ip_addresses = {
      node_1 = "${cidrhost(cidrsubnet(var.vnet_cidr, 2, 1), 11)}"
      node_2 = "${cidrhost(cidrsubnet(var.vnet_cidr, 2, 1), 12)}"
      node_3 = "${cidrhost(cidrsubnet(var.vnet_cidr, 2, 1), 13)}"
  }
}


#Use template file for consul server config
data "template_file" "consul_config" {

  count = 3

  template = "${file("./consul.tpl")}"

  vars {
      node_ip_address = "${cidrhost(cidrsubnet(var.vnet_cidr, 2, 1), (10 + count.index))}"
      node_1_ip_address = "${lookup(local.node_ip_addresses,"node_1")}"
      node_2_ip_address = "${lookup(local.node_ip_addresses,"node_2")}"
      node_3_ip_address = "${lookup(local.node_ip_addresses,"node_3")}"
      encrypt_key = "${var.consul_key}"
  }
}


###################################################################################
# RESOURCES
###################################################################################

#Create VNet
module "vnet" {
  source = "source"
  
}

#Create VM Instances
