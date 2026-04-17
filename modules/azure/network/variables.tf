variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "location" {
  description = "Região Azure (ex: westeurope)"
  type        = string
}

# Estrutura VNET's
variable "ADDRESS" {
  description = "VNET HUB Azure"
  type = list(string)
}

variable "Azure_Subnets_prefixes"{
  description =  "Azure Subnets"
  type = list(string)
}

variable "Azure_Subnet_names"{
  description =  "Azure Subnet name"
  type = list(string)
}

