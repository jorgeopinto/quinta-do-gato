vpn_s2s = {
  hub1 = {
    enabled              = true

    type                 = "Vpn"
    vpn_type             = "RouteBased"
    active_active        = false
    enable_bgp           = false
    sku                  = "VpnGw1AZ"

    onprem_public_ip     = "85.241.235.71"
    onprem_address_space = ["192.168.0.0/24"]
    shared_key           = "CHAVE_SUPER_SECRETA"
  }
}
