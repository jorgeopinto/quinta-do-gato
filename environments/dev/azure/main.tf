terraform {

  required_version = ">=1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.63.0"
    }
  }
}

provider "azurerm" {
  features {}
}



module "network" {
  source              = "../../../modules/azure/network"
  resource_group_name = "QDG_network_dev"
  location = "west europe"
  HUB_VNET            = ["10.0.0.0/16"]
  Azure_Subnet_names = [
    "compute-subnet",
    "storage-subnet"
  ]
  Azure_Subnets_prefixes = [
    "10.0.1.0/24", #compute-subnet
    "10.0.2.0/24"  #storage-subnet
  ]
}

module "compute" {
  source              = "../../../modules/azure/compute"
  resource_group_name = "QDG_network_dev"
  prefix              = "myapp-dev"
  vm_size             = "Standard_D2s_v3"
  subnet_id           = module.network.subnet_id[0]
  admin_user      = "jorge"
  azure_key_pub = file("../../../modules/azure/compute/azure_key.pub")
  }