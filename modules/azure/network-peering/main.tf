#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke1"
  resource_group_name       = "QDG_network_dev"
  virtual_network_name      = module.network.vnet_name
  remote_virtual_network_id = module.spoke1.vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke1-to-hub"
  resource_group_name       = "QDG_network_dev"
  virtual_network_name      = module.spoke1.vnet_name
  remote_virtual_network_id = module.network.vnet_id
  allow_forwarded_traffic   = true
  use_remote_gateways       = true
}