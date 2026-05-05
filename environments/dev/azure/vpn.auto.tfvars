vpn_s2s = {
  hub1 = {
    enabled              = false

    #VPN Gateway
    type                 = "Vpn"
    vpn_type             = "RouteBased"
    active_active        = false
    
    enable_bgp           = false
    azure_bgp_asn     = 65515
    #Tambem pode ser usado APIPA
    azure_bgp_peer_ip = "10.10.255.30"   # IP BGP do Azure (dentro do GatewaySubnet)

    sku                  = "VpnGw1AZ"
    
    # Public IP do Gateway
    pip_allocation_method = "Static"
    pip_sku               = "Standard"
    pip_zones             = ["1", "2", "3"]

    # Segundo PIP (só usado se active_active = true)
    pip2_allocation_method = "Static"
    pip2_sku               = "Standard"
    pip2_zones             = ["1", "2", "3"]
    
    # Vários sites on‑prem
    sites = {
      aqui = {
        onprem_public_ip     = "85.241.235.71"
        onprem_address_space = [
          "192.168.0.0/24",
          "192.168.1.0/24"
        ]
        
        onprem_bgp_asn        = 65001
        onprem_bgp_peer_ip    = "192.168.0.1"
        
        shared_key = "CHAVE_SUPER_SECRETA_1"
      }

      acola = {
        onprem_public_ip     = "90.10.10.10"
        onprem_address_space = [
          "10.10.0.0/24"
        ]
        shared_key = "CHAVE_SUPER_SECRETA_2"

        onprem_bgp_asn        = 65002
        onprem_bgp_peer_ip    = "10.10.0.1"
      }
    }  
  }
}
