##################################
#       VNET-PEERINGS            #
##################################

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke1"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.HUB_VNET_name
  remote_virtual_network_id = var.HUB_VNET_id

  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
  use_remote_gateways = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke1-to-hub"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.SPOKE_VNET_name
  remote_virtual_network_id = var.SPOKE_VNET_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = true
}