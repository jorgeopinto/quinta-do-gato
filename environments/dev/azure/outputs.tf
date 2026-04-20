output "hub_vnet_id" {
  description = "ID da VNet Hub"
  value       = module.hub_vnet.vnet_id
}

output "hub_vnet_name" {
  description = "Nome da VNet Hub"
  value       = module.hub_vnet.vnet_name
}

output "hub_subnet_ids" {
  description = "IDs das subnets do Hub"
  value       = module.hub_vnet.subnet_ids
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