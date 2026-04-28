variable "resource_group_name" {
  description = "Nome do Resource Group onde as VMs serão criadas"
  type        = string
}

variable "location" {
  description = "Região Azure"
  type        = string
}

variable "tags" {
  description = "Tags a aplicar nos recursos"
  type        = map(string)
  default     = {}
}

variable "virtual_machines" {
  description = "Mapa de definições de VMs Linux"
  type = map(object({
    name           = string
    vm_size        = string
    subnet_id      = string
    os_disk_type   = optional(string, "Standard_LRS")
    os_disk_size_gb = optional(number, 30)
    image = optional(object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    }), {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-focal"
      sku       = "20_04-lts-gen2"
      version   = "latest"
    })
    admin_username  = string
    
  }))
  default = {}
}
/*
variable "admin_username"{
  description = "Username Admin for machines"
  type = string
}
*/
variable "AZURE_KEY_PUB" {
  description = "Chave SSH pública para acesso às VMs"
  type        = string
  sensitive   = true
}



/*
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
*/
