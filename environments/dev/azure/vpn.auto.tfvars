vpn_s2s = {
  hub1 = {
    enabled              = true

    #VPN Gateway
    type                 = "Vpn"
    vpn_type             = "RouteBased"
    active_active        = false
    enable_bgp           = false
    sku                  = "VpnGw1AZ"
    
    # Public IP do Gateway
    pip_allocation_method = "Static"
    pip_sku               = "Standard"
    pip_zones             = ["1", "2", "3"]

    # Segundo PIP (só usado se active_active = true)
    pip2_allocation_method = "Static"
    pip2_sku               = "Standard"
    pip2_zones             = ["1", "2", "3"]
    
    #ON-PREM
    onprem_public_ip     = "85.241.235.71"
    onprem_address_space = [
      "192.168.0.0/24",
      "192.168.1.0/24"
      ]
    shared_key           = "CHAVE_SUPER_SECRETA"
  }
}
