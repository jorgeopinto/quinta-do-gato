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

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-JOP-P3"
    storage_account_name = "jorgepintotstate"
    container_name       = "remote-state"
    key                  = "quintadogato/terraform.tfstate"
  }
}

# ─────────────────────────────────────────
# Resource Groups
# ─────────────────────────────────────────

resource "azurerm_resource_group" "hub" {
  name     = var.hub_resource_group_name
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_resource_group" "spokes" {
  for_each = var.spokes

  name     = each.value.resource_group_name
  location = var.location
  tags     = var.common_tags
}


######################
#        VNETS       #
######################


module "hub_vnet" {
  source              = "../../../modules/azure/network"

  name = var.hub_vnet_name
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  address_space = [var.hub_address_space]
  tags = var.common_tags

  subnets = [
    {
      name             = "GatewaySubnet"
      address_prefixes = [var.hub_gateway_subnet_prefix]
    },
    {
      name             = "AzureFirewallSubnet"
      address_prefixes = [var.hub_firewall_subnet_prefix]
    },
    {
      name             = "snet-management"
      address_prefixes = [var.hub_management_subnet_prefix]
    },
    {
      name             = "snet-nva"
      address_prefixes = [var.hub_nva_subnet_prefix]
    }
  ]

  depends_on = [azurerm_resource_group.hub]

}


# ─────────────────────────────────────────
# Spoke VNets (dinâmico via variável)
# ─────────────────────────────────────────

module "spoke_vnets" {
  source              = "../../../modules/azure/network"
  for_each = var.spokes

  name                = each.value.vnet_name
  resource_group_name = azurerm_resource_group.spokes[each.key].name
  location            = var.location
  address_space       = [each.value.address_space]
  tags                = merge(var.common_tags, each.value.tags)

  subnets = each.value.subnets

  #depends_on = [azurerm_resource_group.spokes]
}

##################################
#       VNET-PEERINGS            #
##################################

module "hub_spoke_peerings" {
  source = "../../../modules/azure/network/vnet_peerings"
  for_each = var.spokes


  hub_vnet_name             = module.hub_vnet.vnet_name
  hub_vnet_id               = module.hub_vnet.vnet_id
  hub_resource_group_name   = azurerm_resource_group.hub.name

  spoke_vnet_name           = module.spoke_vnets[each.key].vnet_name
  spoke_vnet_id             = module.spoke_vnets[each.key].vnet_id
  spoke_resource_group_name = azurerm_resource_group.spokes[each.key].name

  allow_gateway_transit   = var.enable_gateway_transit
  use_remote_gateways     = var.enable_gateway_transit
  allow_forwarded_traffic = true

  depends_on = [module.hub_vnet, module.spoke_vnets]
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
  
  */