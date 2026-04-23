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
  for_each = var.hubs
  
  name     = each.value.hub_resource_group_name
  location = var.location
  tags     = var.common_tags
}

resource "azurerm_resource_group" "spokes" {
  for_each = var.spokes

  name     = each.value.resource_group_name
  location = var.location
  tags     = var.common_tags
}


# ─────────────────────────────────────────
# HUB VNets (dinâmico via variável)
# ─────────────────────────────────────────


module "hub_vnet" {
  source              = "../../../modules/azure/network"
  for_each = var.hubs

  name                = each.value.hub_vnet_name
  resource_group_name = azurerm_resource_group.hub[each.key].name
  location            = var.location
  address_space       = [each.value.hub_address_space]
  tags                = merge(var.common_tags, each.value.tags)

  subnets = each.value.subnets

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

  depends_on = [azurerm_resource_group.spokes]
}

# ─────────────────────────────────────────────────────
# Vnet Peerings
# Static. advertizement routes from a gateway
# can be controled using a UDR associated to a subnet
# ─────────────────────────────────────────────────────


module "hub_spoke_peerings" {
  source = "../../../modules/azure/network/vnet_peerings"
  for_each = var.spokes

  #HUB (dinâmico, depende do spoke)
  hub_vnet_name             = module.hub_vnet[each.value.hub].vnet_name
  hub_vnet_id               = module.hub_vnet[each.value.hub].vnet_id
  hub_resource_group_name   = azurerm_resource_group.hub[each.value.hub].name

  # Hub → Spoke
  HUB-TO-SPOKE-allow_virtual_network_access = var.HUB-TO-SPOKE-allow_virtual_network_access
  HUB-TO-SPOKE-allow_forwarded_traffic      = var.HUB-TO-SPOKE-allow_forwarded_traffic
  HUB-TO-SPOKE-allow_gateway_transit        = var.HUB-TO-SPOKE-allow_allow_gateway_transit
  HUB-TO-SPOKE-use_remote_gateways          = var.HUB-TO-SPOKE-allow_use_remote_gateways
  
  


  #SPOKE (cada spoke)
  spoke_vnet_name           = module.spoke_vnets[each.key].vnet_name
  spoke_vnet_id             = module.spoke_vnets[each.key].vnet_id
  spoke_resource_group_name = azurerm_resource_group.spokes[each.key].name

  # Spoke → Hub
  SPOKE-TO-HUB-allow_virtual_network_access = var.SPOKE-TO-HUB-allow_virtual_network_access
  SPOKE-TO-HUB-allow_forwarded_traffic      = var.SPOKE-TO-HUB-allow_forwarded_traffic
  SPOKE-TO-HUB-allow_gateway_transit        = var.HUB-TO-SPOKE-allow_allow_gateway_transit
  SPOKE-TO-HUB-use_remote_gateways          = var.HUB-TO-SPOKE-allow_use_remote_gateways
  

  depends_on = [module.hub_vnet, module.spoke_vnets]
}

# ─────────────────────────────────────────
# NSGs por Subnet (Hub)
# ─────────────────────────────────────────

module "hub_nsgs" {
  source   = "../../../modules/azure/network/nsg"
  for_each = var.hubs

  resource_group_name = azurerm_resource_group.hub[each.key].name
  location            = var.location
  tags                = merge(var.common_tags, each.value.tags)

  # Filtra subnets do hub que tenham regras NSG definidas
  subnets = {
    for s in each.value.subnets :
    s.name => {
      subnet_id = module.hub_vnet[each.key].subnet_ids[s.name]
      rules     = s.nsg_rules
    }
    if length(s.nsg_rules) > 0
  }

  depends_on = [module.hub_vnet]
}
# ─────────────────────────────────────────
# NSGs por Subnet (Spokes)
# ─────────────────────────────────────────

module "spoke_nsgs" {
  source   = "../../../modules/azure/network/nsg"
  for_each = var.spokes

  resource_group_name = azurerm_resource_group.spokes[each.key].name
  location            = var.location
  tags                = merge(var.common_tags, each.value.tags)

  # Filtra subnets do Spoke que tenham regras NSG definidas
  subnets = {
    for s in each.value.subnets :
    s.name => {
      subnet_id = module.spoke_vnets[each.key].subnet_ids[s.name]
      rules     = s.nsg_rules
    }
    if length(s.nsg_rules) > 0
  }

  depends_on = [module.spoke_vnets]
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