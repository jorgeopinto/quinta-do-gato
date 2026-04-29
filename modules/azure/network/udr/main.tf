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
    subnet_name => subnet.routes
    if length(subnet.routes) > 0
  }

  for route in each.value : {
    name                   = route.name
    resource_group_name    = var.resource_group_name
    route_table_name       = azurerm_route_table.rt[each.key].name
    address_prefix         = route.address_prefix
    next_hop_type          = route.next_hop_type
    next_hop_in_ip_address = lookup(route, "next_hop_in_ip_address", null)
  }
}
