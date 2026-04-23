variable "hub_vnet_name" {
  description = "Nome da VNet Hub"
  type        = string
}

variable "hub_vnet_id" {
  description = "ID da VNet Hub"
  type        = string
}

variable "hub_resource_group_name" {
  description = "Resource Group da VNet Hub"
  type        = string
}

variable "spoke_vnet_name" {
  description = "Nome da VNet Spoke"
  type        = string
}

variable "spoke_vnet_id" {
  description = "ID da VNet Spoke"
  type        = string
}

variable "spoke_resource_group_name" {
  description = "Resource Group da VNet Spoke"
  type        = string
}

#----------------------------------------
#peering parameters
#----------------------------------------

variable "hub_to_spoke_allow_virtual_network_access" {
  description = "Permite tráfego entre VNets. normalmente true"
  type        = bool
  #default     = true
}
variable "hub_to_spoke_allow_forwarded_traffic" {
  description = "Permite tráfego que foi roteado por um appliance (firewall, NVA). Usado quando tens firewalls, Azure Firewall, appliances virtuais. dá igual que seja tru or false se nao tiver NVA."
  type        = bool
  #default     = true
}

variable "hub_to_spoke_allow_gateway_transit" {
  description = "Permite que a VNet local ofereça o seu gateway VPN/ExpressRoute à outra VNet. True do lado do HUB"
  type        = bool
  #default     = true
}

variable "hub_to_spoke_use_remote_gateways" {
  description = "Permite que a VNet local use o gateway da VNet remota. Só pode ser usada de um dos lados como true, clarament do lado oda spokes."
  type        = bool
  #default     = false
}

#--------

variable "spoke_to_hub_allow_virtual_network_access" {
  description = "Permite tráfego entre VNets. normalmente true"
  type        = bool
  #default     = true
}
variable "spoke_to_hub_allow_forwarded_traffic" {
  description = "Permite tráfego que foi roteado por um appliance (firewall, NVA). Usado quando tens firewalls, Azure Firewall, appliances virtuais. dá igual que seja tru or false se nao tiver NVA."
  type        = bool
  #default     = true
}

variable "spoke_to_hub_allow_gateway_transit" {
  description = "Permite que a VNet local ofereça o seu gateway VPN/ExpressRoute à outra VNet. True do lado do HUB"
  type        = bool
  #default     = false
}

variable "spoke_to_hub_use_remote_gateways" {
  description = "Permite que a VNet local use o gateway da VNet remota. Só pode ser usada de um dos lados como true, clarament do lado oda spokes."
  type        = bool
  #default     = true
}



