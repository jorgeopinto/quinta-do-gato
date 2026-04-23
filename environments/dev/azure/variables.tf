variable "azure_key_pub" {
  description = "chave public para maquina Azure"
  type        = string
}

#─────────────────────────────────────
#Declarar variaveis a usar para um HUB
#─────────────────────────────────────

variable "location" {
  description = "Região Azure para todos os recursos"
  type        = string
  #default     = "westeurope"
}


variable "hubs" {
  description = "Mapa de configurações dos Spokes"
  type = map(object({
    hub_resource_group_name = string
    hub_vnet_name           = string
    hub_address_space       = string
    tags                = map(string)
    subnets = list(object({
      name             = string
      address_prefixes = list(string)
      nsg_rules = optional(list(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
      })), [])
    }))
  }))
}


#───────────────────────────────────────────────
#Declarar variaveis a usar para um HUB com NSG
#───────────────────────────────────────────────

variable "spokes" {
  description = "Mapa de configurações dos Spokes"
  type = map(object({
    hub = string
    resource_group_name = string
    vnet_name           = string
    address_space       = string
    tags                = map(string)
    subnets = list(object({
      name             = string
      address_prefixes = list(string)
      nsg_rules = optional(list(object({
        name                       = string
        priority                   = number
        direction                  = string
        access                     = string
        protocol                   = string
        source_port_range          = string
        destination_port_range     = string
        source_address_prefix      = string
        destination_address_prefix = string
      })), [])
    }))
  }))
}


#─────────────────────────────────────
#Declarar variaveis a usar em tags
#─────────────────────────────────────


variable "common_tags" {
  description = "Tags comuns a todos os recursos"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Environment = "dev"
    Project     = "hub-spoke"
  }
}

#─────────────────────────────────────
#Declarar variaveis a usar em peerings
#─────────────────────────────────────
variable "HUB-TO-SPOKE-allow_virtual_network_access" {
  description = "HUB TO SPOKE -> virtual network access"
  type        = bool
}
variable "HUB-TO-SPOKE-allow_forwarded_traffic" {
  description = "HUB TO SPOKE -> virtual network access"
  type        = bool
}
variable "HUB-TO-SPOKE-allow_allow_gateway_transit" {
  description = "HUB TO SPOKE -> virtual network access"
  type        = bool
}
variable "HUB-TO-SPOKE-allow_use_remote_gateways" {
  description = "HUB TO SPOKE -> virtual network access"
  type        = bool
}


variable "SPOKE-TO-HUB-allow_virtual_network_access" {
  description = "HUB TO SPOKE -> virtual network access"
  type        = bool
}
variable "SPOKE-TO-HUB-allow_forwarded_traffic" {
  description = "HUB TO SPOKE -> virtual network access"
  type        = bool
}
variable "SPOKE-TO-HUB-allow_allow_gateway_transit" {
  description = "HUB TO SPOKE -> virtual network access"
  type        = bool
}
variable "SPOKE-TO-HUB-allow_use_remote_gateways" {
  description = "HUB TO SPOKE -> virtual network access"
  type        = bool
}