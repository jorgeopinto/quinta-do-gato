variable "resource_group_name" {
  description = "Nome do Resource Group"
  type        = string
}

variable "prefix"{
  description = "Nome da VM ? "
  type = string
}

variable "vm_size"{
  description = "Tipo de VM a escolher"
  type = string
}

variable "subnet_id"{
  description = "Tipo de VM a escolher"
  type = string
}

variable "admin_user"{
  description = "Username Admin for machines"
  type = string
}
variable "azure_key_pub" {
  description = "chave public para maquina Azure"
  type        = string

}
