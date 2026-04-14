#resource groups

resource "azurerm_resource_group" "quinta-do-gato_dev" {
  name     = var.resource_group_name
  location = "west europe"
  #tags = local.common_tags
}


#Network Azure

resource "azurerm_virtual_network" "qdg-HUB-WE" {
  name                = "HUB-${var.resource_group_name}-VNET"
  location            = var.location
  resource_group_name = azurerm_resource_group.quinta-do-gato_dev.name
  address_space       = var.HUB_VNET
  #tags                = local.common_tags
}

resource "azurerm_subnet" "qdg-HUB-WE" {
  count = length(var.Azure_Subnet_names)
  name                 = var.Azure_Subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.quinta-do-gato_dev.name
  virtual_network_name = azurerm_virtual_network.qdg-HUB-WE.name
  address_prefixes     = [var.Azure_Subnets_prefixes[count.index]]
}
# Associar NSG to subnet de Linux
resource "azurerm_subnet_network_security_group_association" "NSG-association-linux-WE" {
  subnet_id                 = azurerm_subnet.qdg-HUB-WE.id
  network_security_group_id = azurerm_network_security_group.qdg-HUB-NSG.id
}

#criação de NSG's 
resource "azurerm_network_security_group" "qdg-HUB-NSG" {
  name                = "acess-to-linux-WE"
  location            = var.location
  resource_group_name = azurerm_resource_group.quinta-do-gato.name

  security_rule {
    name                       = "allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "85.241.235.71/32"
    destination_address_prefix = "10.0.1.0/24"
  }

  security_rule {
    name                       = "Deny-ANY"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "10.0.1.0/24"
  }
}


