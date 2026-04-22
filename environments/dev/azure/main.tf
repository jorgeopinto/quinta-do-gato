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


# ─────────────────────────────────────────
# HUB VNets (dinâmico via variável)
# ─────────────────────────────────────────


module "hub_vnet" {
  source              = "../../../modules/azure/network"

  name                = var.hub_vnet_name
  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  address_space       = [var.hub_address_space]
  tags                = var.common_tags

  subnets = var.subnets

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

##################################
#       VNET-PEERINGS            #
##################################

module "hub_spoke_peerings" {
  source = "../../../modules/azure/network/vnet_peerings"
  for_each = var.spokes

  #HUB
  hub_vnet_name             = module.hub_vnet.vnet_name
  hub_vnet_id               = module.hub_vnet.vnet_id
  hub_resource_group_name   = azurerm_resource_group.hub.name

  # Hub → Spoke
  HUB-TO-SPOKE-allow_virtual_network_access = true
  #Permite tráfego entre VNets. normalmente true

  HUB-TO-SPOKE-allow_forwarded_traffic      = true
  #Permite tráfego que foi roteado por um appliance (firewall, NVA). Usado quando tens firewalls, Azure Firewall, appliances virtuais

  HUB-TO-SPOKE-allow_gateway_transit        = true
  #Permite que a VNet local ofereça o seu gateway VPN/ExpressRoute à outra VNet. True do lado do HUB

  HUB-TO-SPOKE-use_remote_gateways          = false
  #Permite que a VNet local use o gateway da VNet remota. Só pode ser usada de um dos lados como true, clarament do lado oda spokes.
  


  #SPOKE
  spoke_vnet_name           = module.spoke_vnets[each.key].vnet_name
  spoke_vnet_id             = module.spoke_vnets[each.key].vnet_id
  spoke_resource_group_name = azurerm_resource_group.spokes[each.key].name

  # Spoke → Hub
  SPOKE-TO-HUB-allow_virtual_network_access = true
  #Permite tráfego entre VNets. normalmente true

  SPOKE-TO-HUB-allow_forwarded_traffic      = true
  #Permite tráfego que foi roteado por um appliance (firewall, NVA). Usado quando tens firewalls, Azure Firewall, appliances virtuais

  SPOKE-TO-HUB-allow_gateway_transit        = false
  #Permite que a VNet local ofereça o seu gateway VPN/ExpressRoute à outra VNet. True do lado do HUB
  
  SPOKE-TO-HUB-use_remote_gateways          = false
  #Permite que a VNet local use o gateway da VNet remota. Só pode ser usada de um dos lados como true, clarament do lado oda spokes.

  depends_on = [module.hub_vnet, module.spoke_vnets]
}

# ─────────────────────────────────────────
# NSGs por Subnet (Hub)
# ─────────────────────────────────────────

module "hub_nsgs" {
  source = "../../../modules/azure/network/nsg"

  resource_group_name = azurerm_resource_group.hub.name
  location            = var.location
  tags                = var.common_tags

  # Filtra subnets do Hub que tenham regras NSG definidas
  # Nota: GatewaySubnet e AzureFirewallSubnet não suportam NSG — são excluídas aqui
  subnets = {
    for s in var.hub_subnets :
    s.name => {
      subnet_id = module.hub_vnet.subnet_ids[s.name]
      rules     = s.nsg_rules
    }
    if length(s.nsg_rules) > 0 && !contains(["GatewaySubnet", "AzureFirewallSubnet"], s.name)
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