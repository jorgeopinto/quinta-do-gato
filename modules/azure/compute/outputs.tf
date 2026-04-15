output "vm_azure_ip" {
  description = "Ip da maquina virtual de azure: "
  value       = azurerm_linux_virtual_machine.main.public_ip_address
}