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

hub_to_spoke_allow_virtual_network_access_m = var.hub_to_spoke_allow_virtual_network_access
hub_to_spoke_allow_forwarded_traffic_m     = var.hub_to_spoke_allow_forwarded_traffic
hub_to_spoke_allow_gateway_transit_m        = var.hub_to_spoke_allow_gateway_transit
hub_to_spoke_use_remote_gateways_m          = var.hub_to_spoke_use_remote_gateways






  #SPOKE (cada spoke)
  spoke_vnet_name           = module.spoke_vnets[each.key].vnet_name
  spoke_vnet_id             = module.spoke_vnets[each.key].vnet_id
  spoke_resource_group_name = azurerm_resource_group.spokes[each.key].name

  # Spoke → Hub

  spoke_to_hub_allow_virtual_network_access_m = var.spoke_to_hub_allow_virtual_network_access
  spoke_to_hub_allow_forwarded_traffic_m      = var.spoke_to_hub_allow_forwarded_traffic
  spoke_to_hub_allow_gateway_transit_m        = var.spoke_to_hub_allow_gateway_transit
  spoke_to_hub_use_remote_gateways_m          = var.spoke_to_hub_use_remote_gateways


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
# UDRSs por Subnet (Hub)
# ─────────────────────────────────────────
module "hub_udrs" {
  source   = "../../../modules/azure/network/udr"
  for_each = var.hubs

  resource_group_name = azurerm_resource_group.hub[each.key].name
  location            = var.location
  tags                = merge(var.common_tags, each.value.tags)

  subnets = {
    for s in each.value.subnets :
    s.name => {
      subnet_id = module.hub_vnet[each.key].subnet_ids[s.name]
      routes    = s.udr_routes
      propagate_gateway_routes = lookup(s, "propagate_gateway_routes", true)
    }
    if length(s.udr_routes) > 0
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

module "spoke_udrs" {
  source   = "../../../modules/azure/network/udr"
  for_each = var.spokes

  resource_group_name = azurerm_resource_group.spokes[each.key].name
  location            = var.location
  tags                = merge(var.common_tags, each.value.tags)

  subnets = {
    for s in each.value.subnets :
    s.name => {
      subnet_id = module.spoke_vnets[each.key].subnet_ids[s.name]
      routes    = s.udr_routes
    }
    if length(s.udr_routes) > 0
  }

  depends_on = [module.spoke_vnets]
}


# ─────────────────────────────────────────
# NSGs por Subnet (spoke)
# ─────────────────────────────────────────
  


######################
#        VMS         #
######################
# ─────────────────────────────────────────
# Locals: preparar VMs Hub com subnet_id resolvido
# ─────────────────────────────────────────

locals {
  # Flatten das VMs de Hub com suporte a count
  # Expande cada definição em N entradas: "hub_key|vm_key-001", "hub_key|vm_key-002", ...
  hub_vms_flat = {
    for pair in flatten([
      for hub_key, vms in var.hub_virtual_machines : [
        for vm_key, vm in vms : [
          for i in range(vm.count) : {
            key     = vm.count == 1 ? "${hub_key}|${vm_key}" : "${hub_key}|${vm_key}-${format("%03d", i + 1)}"
            hub_key = hub_key
            vm_key = vm.count == 1 ? vm_key : "${vm_key}-${format("%03d", i + 1)}"
            vm = merge(vm, {
              name = vm.count == 1 ? vm.name : "${vm.name}-${format("%03d", i + 1)}"
            })
          }
        ]
      ]
    ]) : pair.key => pair
  }

  # Flatten das VMs de Spoke com suporte a count
  # Expande cada definição em N entradas: "spoke_key|vm_key-001", "spoke_key|vm_key-002", ...
  spoke_vms_flat = {
    for pair in flatten([
      for spoke_key, vms in var.spoke_virtual_machines : [
        for vm_key, vm in vms : [
          for i in range(vm.count) : {        # ← expande pelo count
            key       = "${spoke_key}|${vm_key}-${format("%03d", i + 1)}"
            spoke_key = spoke_key
            vm_key = vm.count == 1 ? vm_key : "${vm_key}-${format("%03d", i + 1)}"
            vm        = merge(vm, {
              name = "${vm.name}-${format("%03d", i + 1)}"   # vm-spoke2-app-001, 002...
            })
          }
        ]
      ]
    ]) : pair.key => pair
  }
}

# ─────────────────────────────────────────
# VMs no Hub
# ─────────────────────────────────────────

module "hub_vms" {
  source   = "../../../modules/azure/compute"
  for_each = local.hub_vms_flat
  AZURE_KEY_PUB       = var.AZURE_KEY_PUB
  

  resource_group_name = azurerm_resource_group.hub[each.value.hub_key].name
  location            = var.location
  tags                = merge(var.common_tags, var.hubs[each.value.hub_key].tags)

  virtual_machines = {
    (each.value.vm_key) = {
      name            = each.value.vm.name
      vm_size         = each.value.vm.vm_size
      subnet_id       = module.hub_vnet[each.value.hub_key].subnet_ids[each.value.vm.subnet_name]
      os_disk_type    = each.value.vm.os_disk_type
      os_disk_size_gb = each.value.vm.os_disk_size_gb
      image           = each.value.vm.image

      admin_username  = each.value.vm.admin_username

    }
  }

  depends_on = [module.hub_vnet]
}

# ─────────────────────────────────────────
# VMs nos Spokes
# ─────────────────────────────────────────

module "spoke_vms" {
  source   = "../../../modules/azure/compute"
  for_each = local.spoke_vms_flat
  AZURE_KEY_PUB       = var.AZURE_KEY_PUB
  

  resource_group_name = azurerm_resource_group.spokes[each.value.spoke_key].name
  location            = var.location
  tags                = merge(var.common_tags, var.spokes[each.value.spoke_key].tags)

  virtual_machines = {
    (each.value.vm_key) = {
      name            = each.value.vm.name
      vm_size         = each.value.vm.vm_size
      subnet_id       = module.spoke_vnets[each.value.spoke_key].subnet_ids[each.value.vm.subnet_name]
      os_disk_type    = each.value.vm.os_disk_type
      os_disk_size_gb = each.value.vm.os_disk_size_gb
      image           = each.value.vm.image

      admin_username  = each.value.vm.admin_username
      #ssh_public_key  = each.value.vm.ssh_public_key
    }
  }

  depends_on = [module.spoke_vnets]
}
