output "vnet_HUB_id" {
 value = azurerm_virtual_network.qdg-HUB-WE.id 
}

output "vnet_SPOKE_id" {
 value = azurerm_virtual_network.qdg-SPOKE-WE[*].id 
}
output "vnet_HUB_name" {
 value = azurerm_virtual_network.qdg-HUB-WE.name 
}

output "vnet_SPOKE_name" {
 value = azurerm_virtual_network.qdg-SPOKE-WE[*].name
}

#########

output "subnet_id" {
    value = azurerm_subnet.qdg-SUBNETS-WE[*].id  
}

output "location" {
 value = azurerm_virtual_network.qdg-HUB-WE.location 
}

#########
output "resource_group_name" {
 value = azurerm_resource_group.qdg_network_dev.name
}