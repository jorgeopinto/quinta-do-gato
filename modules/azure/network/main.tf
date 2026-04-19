#resource groups

resource "azurerm_resource_group" "qdg_network_dev" {
  name     = var.resource_group_name
  location = var.location
  #tags = local.common_tags
}


#Network Azure
/*
resource "azurerm_virtual_network" "qdg-HUB-WE" {
  name                = "HUB-${var.resource_group_name}-VNET"
  location            = azurerm_resource_group.qdg_network_dev.location
  resource_group_name = azurerm_resource_group.qdg_network_dev.name
  address_space       = var.ADDRESS-HUB
  #tags                = local.common_tags
}

resource "azurerm_virtual_network" "qdg-SPOKE-WE" {
  name                = "SPOKE-${var.resource_group_name}-VNET"
  location            = azurerm_resource_group.qdg_network_dev.location
  resource_group_name = azurerm_resource_group.qdg_network_dev.name
  address_space       = var.ADDRESS-SPOKE
  #tags                = local.common_tags
}
*/
resource "azurerm_virtual_network" "vnet-qdg" {
  name                = "${var.vnet_type}-dev-vnet"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}


resource "azurerm_subnet" "qdg-SUBNETS-WE" {
  count = length(var.Azure_Subnet_names)
  name                 = var.Azure_Subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.qdg_network_dev.name
  virtual_network_name = azurerm_virtual_network.vnet-qdg.name
  address_prefixes     = [var.Azure_Subnets_prefixes[count.index]]
}
# Associar NSG to subnet de Linux
resource "azurerm_subnet_network_security_group_association" "NSG-association-linux-WE" {
  count                     = length(var.Azure_Subnet_names)
  subnet_id                 = azurerm_subnet.qdg-SUBNETS-WE[count.index].id
  network_security_group_id = azurerm_network_security_group.qdg-HUB-NSG.id
}

#criação de NSG's 
resource "azurerm_network_security_group" "qdg-HUB-NSG" {
  name                = "ONLY-ALLOW-SSH"
  location            = azurerm_resource_group.qdg_network_dev.location
  resource_group_name = azurerm_resource_group.qdg_network_dev.name

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


/*
diferentes nsgs por subnet

variable "Azure_NSG_ids" {
  type = list(string)
  # cada índice corresponde à subnet do mesmo índice
}

resource "azurerm_subnet_network_security_group_association" "qdg-HUB-WE" {
  count                     = length(var.Azure_Subnet_names)
  subnet_id                 = azurerm_subnet.qdg-HUB-WE[count.index].id
  network_security_group_id = var.Azure_NSG_ids[count.index]
}
*/

