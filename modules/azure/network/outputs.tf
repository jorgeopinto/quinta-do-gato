output "vnet_HUB_id" {
 value = azurerm_virtual_network.qdg-HUB-WE.id 
}

output "vnet_SPOKE_id" {
 value = azurerm_virtual_network.qdg-SPOKE-WE[*].id 
}

output "subnet_id" {
    value = azurerm_subnet.qdg-SUBNETS-WE[*].id  
}
