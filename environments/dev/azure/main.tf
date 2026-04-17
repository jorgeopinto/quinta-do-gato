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

######################
#        VNETS       #
######################

module "vnet-hub" {
  source = "../../../modules/azure/network"
  resource_group_name = "QDG_network_dev"
  location = "west europe"
  ADDRESS = ["10.0.0.0/16"]
  Azure_Subnet_names = [
    "GatewaySubnet",
    "AzureFirewallSubnet",
    "NVA"
  ]
  Azure_Subnets_prefixes = [
    "10.0.1.0/24", #0-GatewaySubnet
    "10.0.2.0/24", #1-AzureFirewallSubnet
    "10.0.3.0/24"  #2-NVA
  ]
}
module "vnet-spoke" {
  source = "../../../modules/azure/network"
  resource_group_name = "QDG_network_dev"
  location = module.vnet-hub.location
  ADDRESS = ["10.1.0.0/16"]
  Azure_Subnet_names = [
    "compute-subnet",
    "storage-subnet",
    "kubernets-subnet"
  ]
  Azure_Subnets_prefixes = [
    "10.1.1.0/24", #0-compute-subnet
    "10.1.2.0/24", #1-Storage-subnet
    "10.1.3.0/24"  #2-kubernets-subnet
  ]
}

##################################
#       VNET-PEERINGS            #
##################################

module "hub_spoke1_peering" {
  source = "../../../modules/azure/network/vnet_peerings"

  HUB_VNET_id   = module.vnet-hub.vnet_HUB_id
  HUB_VNET_name = module.vnet-hub.vnet_HUB_name
  resource_group_name= module.vnet-hub.resource_group_name

  SPOKE_VNET_id = module.vnet-spoke.vnet_SPOKE_id
  SPOKE_VNET_name =module.vnet-spoke.vnet_HUB_name
  
}


######################
#        VMS         #
######################
/*
Para vms em diferentes subnets
entra: no modulo for_each = local.vm_definitions e sai count
subnet id passa a ser: subnet_id = module.network.subnet_id[each.value.subnet]

locals {
  vm_definitions = {
    vm1 = { prefix = "Linux_VM_1", subnet = 0 }
    vm2 = { prefix = "Linux_VM_2", subnet = 1 }
    vm3 = { prefix = "Linux_VM_3", subnet = 0 }
  }
}
*/
module "compute" {
  source              = "../../../modules/azure/compute"
  count = 1
  resource_group_name = "QDG_compute_dev"
  prefix              = "Linux-VM-${count.index + 1}"
  vm_size             = "Standard_D2s_v3"
  subnet_id           = module.vnet-spoke.subnet_id[0]
  admin_user      = "jorge"
  azure_key_pub = var.azure_key_pub
  }