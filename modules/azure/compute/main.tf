
resource "azurerm_resource_group" "qdg_compute_dev" {
  name     = var.resource_group_name
  location = "west europe"
  #tags = local.common_tags
}


# Linux Machine Standard_D2s_v3: 
resource "azurerm_public_ip" "PublicIP-to-linux1" {
  name                = "PublicIP-to-linux1"
  resource_group_name = azurerm_resource_group.qdg_compute_dev.name
  location            = azurerm_resource_group.qdg_compute_dev.location
  allocation_method   = "Static"

}

resource "azurerm_network_interface" "LinuxNIC-1" {
  name                = "LinuxNIC-1"
  location            = azurerm_resource_group.qdg_compute_dev.location
  resource_group_name = azurerm_resource_group.qdg_compute_dev.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.PublicIP-to-linux1.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.qdg_compute_dev.name
  location            = azurerm_resource_group.qdg_compute_dev.location
  size                = var.vm_size
  admin_username      = var.admin_user
  network_interface_ids = [
    azurerm_network_interface.LinuxNIC-1.id,
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = var.azure_key_pub
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
 }