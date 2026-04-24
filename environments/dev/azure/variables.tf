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
variable "hub_to_spoke_allow_virtual_network_access" {
  description = "HUB TO SPOKE  virtual network access"
  type        = bool
}
variable "hub_to_spoke_allow_forwarded_traffic" {
  description = "HUB TO SPOKE  allow forwarded traffic"
  type        = bool
}
variable "hub_to_spoke_allow_gateway_transit" {
  description = "HUB TO SPOKE  allow gateway transit"
  type        = bool
}
variable "hub_to_spoke_use_remote_gateways" {
  description = "HUB TO SPOKE  use remote gateways"
  type        = bool
}


variable "spoke_to_hub_allow_virtual_network_access" {
  description = "HUB TO SPOKE  virtual network access"
  type        = bool
}
variable "spoke_to_hub_allow_forwarded_traffic" {
  description = "HUB TO SPOKE  allow virtual network access"
  type        = bool
}
variable "spoke_to_hub_allow_gateway_transit" {
  description = "HUB TO SPOKE  allow gateway transit"
  type        = bool
}
variable "spoke_to_hub_use_remote_gateways" {
  description = "HUB TO SPOKE  use remote gateways"
  type        = bool
}

# ─────────────────────────────────────────
# declarar variaveis a usar para compute (criar VMS)
# ─────────────────────────────────────────
variable "azure_key_pub" {
  description = "chave public para maquina Azure"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave SSH pública para acesso às VMs"
  type        = string
  sensitive   = true
}

variable "hub_virtual_machines" {
  description = "Mapa de VMs a criar no Hub, por hub key"
  type = map(map(object({
    name            = string
    count           = optional(number, 1)
    vm_size         = string
    admin_username  = string
    subnet_name     = string
    os_disk_type    = optional(string, "Standard_LRS")
    os_disk_size_gb = optional(number, 30)
    image = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    }), null)
  })))
  default = {}
}

variable "spoke_virtual_machines" {
  description = "Mapa de VMs a criar nos Spokes, por spoke key"
  type = map(map(object({
    name            = string
    count           = optional(number, 1)
    vm_size         = string
    admin_username  = string
    subnet_name     = string
    os_disk_type    = optional(string, "Standard_LRS")
    os_disk_size_gb = optional(number, 30)
    image = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    }), null)
  })))
  default = {}
}
