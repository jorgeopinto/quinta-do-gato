variable "subnets" {
  description = "Mapa de subnets com as suas rotas UDR"
  type = map(object({
    subnet_id = string
    routes = list(object({
      name                   = string
      address_prefix         = string
      next_hop_type          = string
      next_hop_in_ip_address = optional(string)
    }))
  }))
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "tags"                { type = map(string) }
