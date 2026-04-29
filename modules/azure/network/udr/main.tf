resource "azurerm_route_table" "rt" {
  for_each = var.subnets

  name                = "rt-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_route" "routes" {
  for_each = {
    for subnet_name, subnet in var.subnets :
    # cria um mapa de rotas por subnet
    for route in subnet.routes :
    "${subnet_name}-${route.name}" => {
      subnet_name = subnet_name
      route       = route
    }
    if length(subnet.routes) > 0
  }

  name                   = each.value.route.name
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.rt[each.value.subnet_name].name
  address_prefix         = each.value.route.address_prefix
  next_hop_type          = each.value.route.next_hop_type
  next_hop_in_ip_address = lookup(each.value.route, "next_hop_in_ip_address", null)
}
