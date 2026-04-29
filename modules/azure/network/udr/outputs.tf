output "route_table_ids" {
  description = "IDs das route tables criadas por subnet"
  value = {
    for k, rt in azurerm_route_table.rt :
    k => rt.id
  }
}
output "route_table_names" {
  description = "Nomes das route tables criadas"
  value = {
    for k, rt in azurerm_route_table.rt :
    k => rt.name
  }
}
output "routes" {
  description = "Rotas criadas em cada route table"
  value = {
    for k, v in azurerm_route.routes : k => {
      name                   = v.name
      address_prefix         = v.address_prefix
      next_hop_type          = v.next_hop_type
      next_hop_in_ip_address = v.next_hop_in_ip_address
    }
  }
}