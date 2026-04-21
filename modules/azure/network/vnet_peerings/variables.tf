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

variable "allow_gateway_transit" {
  description = "Permitir gateway transit no Hub"
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Usar gateways remotos no Spoke"
  type        = bool
  default     = false
}

variable "allow_forwarded_traffic" {
  description = "Permitir tráfego encaminhado"
  type        = bool
  default     = true
}

