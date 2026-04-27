# Linux Machine Standard_D2s_v3: 
resource "azurerm_public_ip" "publicIP" {
for_each = { for vm in var.virtual_machines : vm.name => vm }

  name                = "PIP-${each.value.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"

}

# ─────────────────────────────────────────
# Network Interface
# ─────────────────────────────────────────

resource "azurerm_network_interface" "interface" {
  for_each = var.virtual_machines

  name                = "nic-${each.value.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "ipconfig-${each.value.name}"
    subnet_id                     = each.value.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicIP.id
  }
}

# ─────────────────────────────────────────
# Linux Virtual Machine
# ─────────────────────────────────────────

resource "azurerm_linux_virtual_machine" "vm" {
  for_each = var.virtual_machines

  name                  = each.value.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = each.value.vm_size
  admin_username        = each.value.admin_username
  network_interface_ids = [azurerm_network_interface.interface[each.key].id]
  tags                  = var.tags

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = each.value.ssh_public_key
  }

  os_disk {
    name                 = "osdisk-${each.value.name}"
    caching              = "ReadWrite"
    storage_account_type = each.value.os_disk_type
    disk_size_gb         = each.value.os_disk_size_gb
  }

  source_image_reference {
    publisher = each.value.image.publisher
    offer     = each.value.image.offer
    sku       = each.value.image.sku
    version   = each.value.image.version
  }

  disable_password_authentication = true
}


/*

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
 */