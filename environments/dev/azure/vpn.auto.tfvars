vpn_s2s = {
  hub1 = {
    enabled              = true

    #VPN Gateway
    type                 = "Vpn"
    vpn_type             = "RouteBased"
    active_active        = true 
    
    enable_bgp           = true
    azure_bgp_asn     = 65515
    #Usar APIPA: Azure reserved APIPA range: [169.254.21.0, 169.254.22.255]
    azure_bgp_peer_ip = "169.254.21.1"
    azure_bgp_peer_ip2 = "169.254.22.2"

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

        ipsec_policy = {
      # --- Phase 1 (IKE) ---
          ike_encryption   = "AES256"
          ike_integrity    = "SHA256"
          dh_group         = "DHGroup14"

      # --- Phase 2 (IPsec) ---
          ipsec_encryption = "AES256"
          ipsec_integrity  = "SHA256"
          pfs_group        = "PFS2048"

      # Lifetimes
          sa_lifetime_seconds  = 29000
          sa_datasize_kilobytes = 102400000

      #connection mode
          #Default -> qualquer dos lados pode iniciar
          #InitiatorOnly -> Azure inicia o tunnel
          #ResponderOnly -> Azure apenas responde, nunca inicia
          connection_mode      = "InitiatorOnly"
          # de 5 a 240 segundos
          dpd_timeout_seconds  = 30     
    
    } 
      }

      acola = {
        onprem_public_ip     = "90.10.10.10"
        onprem_address_space = [
          "10.10.0.0/24"
        ]
        onprem_bgp_asn        = 65002
        onprem_bgp_peer_ip    = "10.10.0.1"
        
        shared_key = "CHAVE_SUPER_SECRETA_2"


      # Sem ipsec_policy = usa os defaults do Azure
        ipsec_policy = null

      }
    }  
  }
}

/* ipsec_policy possible values
---phase 1 ---
ike_encryption: AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES256
ike_integrity: MD5, SHA1, SHA256, SHA384, GCMAES128, GCMAES256
dh_group: DHGroup1, DHGroup2, DHGroup14, DHGroup24, DHGroup2048, ECP256, ECP384, None
---phase 2 ---
ipsec_encryption: AES128, AES192, AES256, DES, DES3, GCMAES128, GCMAES192, GCMAES256, None
ipsec_integrity: MD5, SHA1, SHA256, GCMAES128, GCMAES192, GCMAES256
pfs_group: ECP256, ECP384, PFS1, PFS2, PFS14, PFS24, PFS2048, PFSMM, None

valores default? 



*/