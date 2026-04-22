output "nsg_ids" {
  description = "Mapa de IDs dos NSGs (nome da subnet => id do NSG)"
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}

output "nsg_names" {
  description = "Mapa de nomes dos NSGs (nome da subnet => nome do NSG)"
  value       = { for k, v in azurerm_network_security_group.this : k => v.name }
}