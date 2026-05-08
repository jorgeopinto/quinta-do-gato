# ─────────────────────────────────────────
# Chave SSH pública (ou usa var de ambiente:
#   export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)
# ─────────────────────────────────────────


# ─────────────────────────────────────────
# VMs no HUB
# Estrutura: hub_key → vm_key → definição
# ─────────────────────────────────────────

hub_virtual_machines = {
  # "hub1" deve corresponder à key do teu map `hubs`
  hub1 = {
    "vm-mgmt" = {
      name           = "vm-hub1-mgmt"
      count          = 0 #reduzir o count vai SEMPRE destruir recursos e recriar.
      #adicionar funciona bem e não causa destruições
      # evitar destruições, tem de se usar keys estáveis e não count
      vm_size        = "Standard_D2s_v3"
      subnet_name    = "snet-NVA"   # nome exato do subnet definido nos hubs
      os_disk_type   = "Standard_LRS"
      os_disk_size_gb = 30
      # image é opcional; não existindo usa Ubuntu 24.04 LTS por defeito declarado nas variaveis do modulo

      #ssh_public_key -> já é injectado no TF_VAR do github
      admin_username = "jorge"
      public_ip = true
    

    }
  }
}


spoke_virtual_machines = {
    spoke3 = {
    "vm-mgmt" = {
      name           = "vm-spoke3-compute"
      count          = 1 #reduzir o count vai SEMPRE destruir recursos e recriar.
      #adicionar funciona bem e não causa destruições
      # evitar destruições, tem de se usar keys estáveis e não count
      vm_size        = "Standard_D2s_v3"
      subnet_name    = "snet-compute"   # nome exato do subnet definido nos hubs
      os_disk_type   = "Standard_LRS"
      os_disk_size_gb = 30
      # image é opcional; não existindo usa Ubuntu 24.04 LTS por defeito declarado nas variaveis do modulo

      #ssh_public_key -> já é injectado no TF_VAR do github
      admin_username = "jorge"
      public_ip = true
    

    }
  }
}
