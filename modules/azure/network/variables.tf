variable "name" {
  description = "Nome da Virtual Network"
  type        = string
}

variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Localização Azure"
  type        = string
}

variable "address_space" {
  description = "Espaço de endereços da VNet"
  type        = list(string)
}

variable "subnets" {
  description = "Lista de subnets a criar"
  type = list(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = []
}


variable "tags" {
  description = "Tags a aplicar nos recursos"
  type        = map(string)
  default     = {}
}

variable "dns_servers" {
  description = "Lista de servidores DNS personalizados"
  type        = list(string)
  default     = []
}

