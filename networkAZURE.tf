#Network Azure

resource "azurerm_virtual_network" "qdg-HUB-WE" {
  name                = "QDG-HUB-WE"
  location            = var.WE
  resource_group_name = azurerm_resource_group.quinta-do-gato.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "acess_to_linux_we" {
  name                 = "acess-to-linux-we"
  resource_group_name  = azurerm_resource_group.quinta-do-gato.name
  virtual_network_name = azurerm_virtual_network.qdg-HUB-WE.name
  address_prefixes     = ["10.0.1.0/24"]
}
# Associar NSG to subnet de Linux
resource "azurerm_subnet_network_security_group_association" "NSG-association-linux-WE" {
  subnet_id                 = azurerm_subnet.acess_to_linux_we.id
  network_security_group_id = azurerm_network_security_group.NSG-acess-to-linux-WE.id
}

#criação de NSG's 
resource "azurerm_network_security_group" "NSG-acess-to-linux-WE" {
  name                = "acess-to-linux-WE"
  location            = var.WE
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


