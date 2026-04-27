output "vm_ids" {
  description = "IDs das VMs criadas"
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.id }
}

output "vm_names" {
  description = "Nomes das VMs criadas"
  value       = { for k, v in azurerm_linux_virtual_machine.vm : k => v.name }
}

output "vm_private_ips" {
  description = "IPs privados das VMs"
  value       = { for k, v in azurerm_network_interface.interface : k => v.private_ip_address }
}

output "vm_public_ip" {
  description = "Ip da maquina virtual de azure: "
  value       = { for k, v in azurerm_linux_virtual_machine.vm.public_ip_address : k => v.id }
}

output "nic_ids" {
  description = "IDs das NICs criadas"
  value       = { for k, v in azurerm_network_interface.interface : k => v.id }
}


