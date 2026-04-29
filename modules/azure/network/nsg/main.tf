# Um NSG por subnet
resource "azurerm_network_security_group" "nsg" {
  for_each = var.subnets

  name                = "nsg-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = each.value.rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol

      # SINGLE VALUES (opcionais)
      source_port_range          = lookup(security_rule.value, "source_port_range", null)
      destination_port_range     = lookup(security_rule.value, "destination_port_range", null)
      source_address_prefix      = lookup(security_rule.value, "source_address_prefix", null)
      destination_address_prefix = lookup(security_rule.value, "destination_address_prefix", null)

      # LISTAS (opcionais)
      source_port_ranges         = lookup(security_rule.value, "source_port_ranges", null)
      destination_port_ranges    = lookup(security_rule.value, "destination_port_ranges", null)
      source_address_prefixes    = lookup(security_rule.value, "source_address_prefixes", null)
      destination_address_prefixes = lookup(security_rule.value, "destination_address_prefixes", null)
    }
  }
}


# Associar cada NSG à sua subnet
resource "azurerm_subnet_network_security_group_association" "nsg" {
  for_each = var.subnets

  subnet_id                 = each.value.subnet_id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}
