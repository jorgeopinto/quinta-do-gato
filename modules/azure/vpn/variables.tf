variable "hub_key" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "gateway_subnet_id" {
  type = string
}

variable "type" {
  type = string
}

variable "vpn_type" {
  type = string
}

variable "active_active" {
  type = bool
}

variable "enable_bgp" {
  type = bool
}

variable "sku" {
  type = string

  validation {
    condition = contains(["VpnGw1AZ", "VpnGw2AZ", "VpnGw3AZ", "VpnGw4AZ", "VpnGw5AZ"], var.sku)
    error_message = "SKU inválido. Apenas SKUs AZ são permitidos: VpnGw1AZ–VpnGw5AZ."
  }
}


variable "onprem_public_ip" {
  type = string
}

variable "onprem_address_space" {
  type = list(string)
}

variable "shared_key" {
  type = string
}

variable "pip_allocation_method" {
  type = string
}

variable "pip_sku" {
  type = string
}

variable "pip_zones" {
  type = list(string)
}