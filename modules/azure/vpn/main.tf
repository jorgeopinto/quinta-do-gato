resource "azurerm_public_ip" "vpn_gw_pip1" {
  name                = "pip-vpngw-${var.hub_key}-1"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method   = var.pip_allocation_method
  sku                 = var.pip_sku
  zones               = var.pip_zones
}

resource "azurerm_public_ip" "vpn_gw_pip2" {
  count               = var.active_active ? 1 : 0
  name                = "pip-vpngw-${var.hub_key}-2"
  location            = var.location
  resource_group_name = var.resource_group_name

  allocation_method   = var.pip2_allocation_method
  sku                 = var.pip2_sku
  zones               = var.pip2_zones
}


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
}

resource "azurerm_local_network_gateway" "onprem" {
  name                = "lng-onprem-${var.hub_key}"
  location            = var.location
  resource_group_name = var.resource_group_name

  gateway_address = var.onprem_public_ip
  address_space   = var.onprem_address_space
}

resource "azurerm_virtual_network_gateway_connection" "s2s" {
  name                = "conn-${var.hub_key}-onprem"
  location            = var.location
  resource_group_name = var.resource_group_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn_gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.onprem.id

  shared_key = var.shared_key
}
