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

variable "hub_resource_group_name" {
  description = "Nome do Resource Group do Hub"
  type        = string
  #default     = "rg-hub-network"
}

variable "hub_vnet_name" {
  description = "Nome da VNet Hub"
  type        = string
  #default     = "vnet-hub"
}

variable "hub_address_space" {
  description = "Bloco CIDR da VNet Hub"
  type        = string
  #default     = "10.0.0.0/16"
}

variable "hub_gateway_subnet_prefix" {
  description = "Prefixo da GatewaySubnet (obrigatório para VPN/ExpressRoute)"
  type        = string
  #default     = "10.0.0.0/26"
}

variable "hub_firewall_subnet_prefix" {
  description = "Prefixo da AzureFirewallSubnet"
  type        = string
  #default     = "10.0.1.0/26"
}

variable "hub_management_subnet_prefix" {
  description = "Prefixo da subnet de gestão"
  type        = string
  #default     = "10.0.2.0/24"
}
variable "hub_nva_subnet_prefix" {
  description = "Prefixo da subnet de uma NVA"
  type        = string
  #default     = "10.0.3.0/24"
}

variable "hub_subnets" {
  description = "Subnets do Hub com regras NSG opcionais"
  type = list(object({
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
}


#───────────────────────────────────────────────
#Declarar variaveis a usar para um HUB com NSG
#───────────────────────────────────────────────

variable "spokes" {
  description = "Mapa de configurações dos Spokes"
  type = map(object({
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