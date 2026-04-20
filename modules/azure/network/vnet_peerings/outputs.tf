output "hub_to_spoke_peering_id" {
  description = "ID do peering Hub → Spoke"
  value       = azurerm_virtual_network_peering.hub_to_spoke.id
}

output "spoke_to_hub_peering_id" {
  description = "ID do peering Spoke → Hub"
  value       = azurerm_virtual_network_peering.spoke_to_hub.id
}