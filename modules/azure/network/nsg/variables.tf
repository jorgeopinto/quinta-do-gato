variable "resource_group_name" {
  description = "Resource Group onde os NSGs serão criados"
  type        = string
}

variable "location" {
  description = "Localização Azure"
  type        = string
}

variable "tags" {
  description = "Tags a aplicar nos recursos"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "Mapa de subnets com as suas regras NSG. A chave é o nome da subnet."
  type = map(object({
    subnet_id = string
    rules = list(object({
      name                       = string
      priority                   = number
      direction                  = string # "Inbound" ou "Outbound"
      access                     = string # "Allow" ou "Deny"
      protocol                   = string # "Tcp", "Udp", "Icmp", "*"
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
  }))
}