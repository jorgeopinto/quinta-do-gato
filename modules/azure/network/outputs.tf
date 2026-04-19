output "vnet_id" {
 value = azurerm_virtual_network.vnet-qdg.id 
}

output "vnet_name" {
 value = azurerm_virtual_network.vnet-qdg.name 
}



#########

output "subnet_id" {
    value = azurerm_subnet.qdg-SUBNETS-WE[*].id  
}

output "location" {
 value = azurerm_virtual_network.vnet-qdg.location 
}

#########
output "resource_group_name" {
 value = azurerm_resource_group.qdg_network_dev.name
}