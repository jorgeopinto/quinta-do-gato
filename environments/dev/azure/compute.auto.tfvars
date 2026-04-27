# ─────────────────────────────────────────
# Chave SSH pública (ou usa var de ambiente:
#   export TF_VAR_ssh_public_key=$(cat ~/.ssh/id_rsa.pub)
# ─────────────────────────────────────────

ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAA... jorge@machine"

# ─────────────────────────────────────────
# VMs no HUB
# Estrutura: hub_key → vm_key → definição
# ─────────────────────────────────────────

hub_virtual_machines = {
  # "hub1" deve corresponder à key do teu map `hubs`
  hub1 = {
    vm-mgmt = {
      name           = "vm-hub1-mgmt"
      count          = 1
      vm_size        = "Standard_B2s"
      admin_username = "jorge"
      subnet_name    = "snet-management"   # nome exato do subnet definido nos hubs
      os_disk_type   = "Standard_LRS"
      os_disk_size_gb = 30
      # image é opcional; sem ele usa Ubuntu 24.04 LTS por defeito
    }
  }
}

# ─────────────────────────────────────────
# VMs nos SPOKES
# Estrutura: spoke_key → vm_key → definição
# ─────────────────────────────────────────

spoke_virtual_machines = {
  # "spoke1" deve corresponder à key do teu map `spokes`
  spoke1 = {
    vm-app = {
      name           = "vm-spoke1-app"
      count          = 1
      vm_size        = "Standard_D2s_v3"
      admin_username = "jorge"
      subnet_name    = "snet-app"          # nome exato do subnet definido nos spokes
      os_disk_type   = "Premium_LRS"
      os_disk_size_gb = 64
    }
    vm-db = {
      name           = "vm-spoke1-db"
      count = 1
      vm_size        = "Standard_D4s_v3"
      admin_username = "jorge"
      subnet_name    = "snet-data"
      os_disk_type   = "Premium_LRS"
      os_disk_size_gb = 128
      # Exemplo com imagem personalizada (ex: Debian)
      image = {
        publisher = "Canonical"
        offer     = "ubuntu-24_04-lts"
        sku       = "server"
        version   = "latest"
      }
    }
  }

  spoke2 = {
    vm-app = {
      name           = "vm-spoke2-app"
      count          = 1 #a quantidade de vms que quero aqui criar
      vm_size        = "Standard_B2s"
      admin_username = "jorge"
      subnet_name    = "snet-app"
      os_disk_type   = "Standard_LRS"
      os_disk_size_gb = 30
    }
  }
}
