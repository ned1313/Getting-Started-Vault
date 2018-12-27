################# VARIABLES ##########################

#Azure info
variable "az_location" {
  default = "eastus"
}
variable "az_resource_group_name" {
    default = "vault-demo"
}

#Azure Credentials
variable "az_subscription" {}
variable "az_client_id" {}
variable "az_tenant_id" {}
variable "az_client_secret" {}

#VNet settings
variable "vnet_cidr" {
  default = "10.0.1.0/22"
}

#Consul info
variable "consul_version" {
  default = "1.4.0"
}

variable "consul_key" {
  default = "BgVgz1dyqCP1d9fyDGwnPw=="
}

