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

# -------------------------
# VPN Gateway settings
# -------------------------

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





# -------------------------
# Public IP 1 (sempre criado)
# -------------------------

variable "pip_allocation_method" {
  type = string
}

variable "pip_sku" {
  type = string
}

variable "pip_zones" {
  type = list(string)
}

# -------------------------
# Public IP 2 (só se Active-Active)
# -------------------------

variable "pip2_allocation_method" {
  type = string
  default = null
}

variable "pip2_sku" {
  type = string
  default = null
}

variable "pip2_zones" {
  type = list(string)
  default = null
}
# -------------------------
# Multi-site On-Premises
# -------------------------

variable "sites" {
  description = "Mapa de sites on-premises para multi-site VPN"
  type = map(object({
    onprem_public_ip     = string
    onprem_address_space = list(string)
    shared_key           = string
    # BGP opcional
    onprem_bgp_asn        = optional(number)
    onprem_bgp_peer_ip    = optional(string)
    #phase1 and phase2 policies
    ipsec_policy = optional(object({
      ike_encryption        = string
      ike_integrity         = string
      dh_group              = string
      ipsec_encryption      = string
      ipsec_integrity       = string
      pfs_group             = string
      sa_lifetime_seconds   = number
      sa_datasize_kilobytes = number
    }))
  }))
}

variable "azure_bgp_asn" {
  type    = number
  default = 65515
}

variable "azure_bgp_peer_ip" {
  type    = string
  default = null
}

variable "azure_bgp_peer_ip2" {
  type    = string
  default = null
  description = "APIPA address para o segundo ip_configuration (active-active + BGP)"
}
/*
variable "connection_mode" {
  type        = string
  default     = "Default"
  description = "Connection mode: Default, InitiatorOnly, or ResponderOnly"
}

variable "dpd_timeout_seconds" {
  type        = number
  default     = 45
  description = "DPD timeout in seconds"
}
*/
