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
      name        = string
      priority    = number
      direction   = string
      access      = string
      protocol    = string

      # SINGLE VALUES (opcionais)
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)

      # LISTAS (opcionais)
      source_port_ranges           = optional(list(string))
      destination_port_ranges      = optional(list(string))
      source_address_prefixes      = optional(list(string))
      destination_address_prefixes = optional(list(string))
    }))
  }))
}
