output "vnet_id" {
  description = "ID da Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Nome da Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "Espaço de endereços da VNet"
  value       = azurerm_virtual_network.vnet.address_space
}

output "subnet_ids" {
  description = "Mapa de IDs das subnets (nome => id)"
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "subnet_names" {
  description = "Lista dos nomes das subnets"
  value       = [for s in azurerm_subnet.subnet : s.name]
}