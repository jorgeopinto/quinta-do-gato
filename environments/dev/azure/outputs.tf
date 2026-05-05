output "hub_vnet_id" {
  description = "ID da VNet Hub"
  value       = { for k, v in module.hub_vnet : k => v.vnet_id }
}

output "hub_vnet_name" {
  description = "Nome da VNet Hub"
  value       = { for k, v in module.hub_vnet : k => v.vnet_id }
}

output "hub_subnet_ids" {
  description = "IDs das subnets do Hub"
  value       = { for k, v in module.hub_vnet : k => v.subnet_ids }
}

output "hub_nsg_ids" {
  description = "IDs dos NSGs do Hub (nome da subnet => id do NSG)"
  value       = { for k, v in module.hub_nsgs : k => v.nsg_ids }
}

output "spoke_vnet_ids" {
  description = "IDs das VNets Spoke"
  value       = { for k, v in module.spoke_vnets : k => v.vnet_id }
}

output "spoke_vnet_names" {
  description = "Nomes das VNets Spoke"
  value       = { for k, v in module.spoke_vnets : k => v.vnet_name }
}

output "spoke_subnet_ids" {
  description = "IDs das subnets por Spoke"
  value       = { for k, v in module.spoke_vnets : k => v.subnet_ids }
}

output "peering_ids" {
  description = "IDs dos peerings Hub ↔ Spoke"
  value = {
    for k, v in module.hub_spoke_peerings : k => {
      hub_to_spoke = v.hub_to_spoke_peering_id
      spoke_to_hub = v.spoke_to_hub_peering_id
    }
  }
}


output "spoke_nsg_ids" {
  description = "IDs dos NSGs por Spoke (spoke => subnet => id do NSG)"
  value       = { for k, v in module.spoke_nsgs : k => v.nsg_ids }
}

output "hub_route_tables" {
  description = "Route tables criadas por hub"
  value = {
    for hub, mod in module.hub_udrs :
    hub => mod.route_table_ids
  }
}
output "hub_routes" {
  description = "Rotas criadas por hub"
  value = {
    for hub, mod in module.hub_udrs :
    hub => mod.routes
  }
}

output "hub1_gateway_ip1" {
  value = module.vpn_s2s["hub1"].vpn_gateway_public_ip1
}
output "hub1_gateway_ip2" {
  value = module.vpn_s2s["hub1"].vpn_gateway_public_ip2
}




