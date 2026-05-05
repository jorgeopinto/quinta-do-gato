###############################################
# Public IP 1 (sempre criado)
###############################################
resource "azurerm_public_ip" "vpn_gw_pip1" {
  name                = "pip-vpngw-${var.hub_key}-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method   = var.pip_allocation_method
  sku                 = var.pip_sku
  zones               = var.pip_zones
}
###############################################
# Public IP 2 (só se Active-Active)
###############################################

resource "azurerm_public_ip" "vpn_gw_pip2" {
  count               = var.active_active ? 1 : 0
  name                = "pip-vpngw-${var.hub_key}-2"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method   = var.pip2_allocation_method
  sku                 = var.pip2_sku
  zones               = var.pip2_zones
}
###############################################
# Virtual Network Gateway
###############################################

resource "azurerm_virtual_network_gateway" "vpn_gw" {
  name                = "vpngw-${var.hub_key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type        = var.type
  vpn_type    = var.vpn_type
  active_active = var.active_active
  bgp_enabled    = var.enable_bgp
  sku           = var.sku

  ip_configuration {
    name                          = "vpngw-ipconfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gw_pip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }
  dynamic "ip_configuration" {
    for_each = var.active_active ? [1] : []
    content {
      name                          = "vpngw-ipconfig2"
      public_ip_address_id          = azurerm_public_ip.vpn_gw_pip2[0].id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = var.gateway_subnet_id
    }
  }
dynamic "bgp_settings" {
  for_each = var.enable_bgp ? [1] : []
  content {
    asn         = var.azure_bgp_asn
    peer_weight = 0

    # Só adiciona o peer IP se existir
    dynamic "peering_addresses" {
      for_each = var.azure_bgp_peer_ip != null ? [1] : []
      content {
        ip_configuration_name = "vpngw-ipconfig"
        apipa_addresses       = [var.azure_bgp_peer_ip]
      }
    }
  }
}

    depends_on = [
    azurerm_public_ip.vpn_gw_pip1,
    azurerm_public_ip.vpn_gw_pip2
  ]
}
###############################################
# Local Network Gateways (um por site)
###############################################

resource "azurerm_local_network_gateway" "onprem" {
  for_each = var.sites

  name                = "lng-${var.hub_key}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  gateway_address = each.value.onprem_public_ip
  address_space   = each.value.onprem_address_space

  dynamic "bgp_settings" {
    for_each = var.enable_bgp ? [1] : []
    content {
      asn                 = each.value.onprem_bgp_asn
      bgp_peering_address = each.value.onprem_bgp_peer_ip
    }
  }

    depends_on = [
    azurerm_virtual_network_gateway.vpn_gw
  ]
}

resource "azurerm_virtual_network_gateway_connection" "s2s" {
  for_each = var.sites

  name                = "conn-${var.hub_key}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem[each.key].id

  shared_key = each.value.shared_key

    depends_on = [
    azurerm_virtual_network_gateway.vpn_gw,
    azurerm_local_network_gateway.onprem
  ]
}
