output "vpn_gateway_public_ip1" {
  description = "Public IP principal do VPN Gateway"
  value       = azurerm_public_ip.vpn_gw_pip1.ip_address
}

output "vpn_gateway_public_ip2" {
  description = "Segundo Public IP do VPN Gateway (Active-Active)"
  value       = var.active_active ? azurerm_public_ip.vpn_gw_pip2[0].ip_address : null
}

output "vpn_gateway_id" {
  value = azurerm_virtual_network_gateway.vpn_gw.id
}

output "vpn_connection_id" {
  value = azurerm_virtual_network_gateway_connection.s2s.id
}

output "local_network_gateway_id" {
  value = azurerm_local_network_gateway.onprem.id
}

output "vpn_gateway_public_ip_name" {
  value = azurerm_public_ip.vpn_gw_pip.name
}

output "vpn_gateway_sku" {
  value = azurerm_virtual_network_gateway.vpn_gw.sku
}

output "vpn_gateway_pip_zones" {
  value = azurerm_public_ip.vpn_gw_pip.zones
}
