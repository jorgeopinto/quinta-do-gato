#Resource group
variable "create_rg" {
  type    = bool
  default = true
}


# Estrutura VNET's
variable "vnet_type" {
  description = "Type of VNet: hub or spoke"
  type        = string

  validation {
    condition     = contains(["hub", "spoke"], var.vnet_type)
    error_message = "vnet_type must be either 'hub' or 'spoke'."
  }
}

variable "address_space" {
  description = "Address space for the VNet"
  type        = list(string)
}

variable "Azure_Subnets_prefixes"{
  description =  "Azure Subnets"
  type = list(string)
}

variable "Azure_Subnet_names"{
  description =  "Azure Subnet name"
  type = list(string)
}


variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Região Azure (ex: westeurope)"
  type        = string
}


