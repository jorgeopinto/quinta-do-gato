##################################
#       VNET-PEERINGS            #
##################################

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke1"
  resource_group_name       = azurerm_resource_group.qdg_network_dev.name
  virtual_network_name      = module.vnet-hub.vnet_name
  remote_virtual_network_id = module.spoke1.vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke1-to-hub"
  resource_group_name       = azurerm_resource_group.qdg_network_dev.name
  virtual_network_name      = module.spoke1.vnet_name
  remote_virtual_network_id = module.network.vnet_id
  allow_forwarded_traffic   = true
  use_remote_gateways       = true
}