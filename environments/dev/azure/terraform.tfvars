location                     = "westeurope"

hubs = {
  hub1 ={
    hub_resource_group_name      = "QDG_network_dev"
    hub_vnet_name                = "vnet-hub"
    hub_address_space            = "10.0.0.0/16"
    tags = {
      Workload = "app"
    }
    hub_subnets = [
      {
        name             = "GatewaySubnet"
       address_prefixes = ["10.0.0.0/27"]
       nsg_rules        = [] # Não suporta NSG — obrigatório estar vazio
      },
      {
        name             = "AzureFirewallSubnet"
        address_prefixes = ["10.0.1.0/26"]
        nsg_rules        = [] # Não suporta NSG — obrigatório estar vazio
      },
      {
        name             = "snet-NVA"
        address_prefixes = ["10.0.2.0/24"]
        nsg_rules = [
          {
            name                       = "allow-ssh-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "22"
            source_address_prefix      = "85.241.235.71/32"
            destination_address_prefix = "10.0.2.0/24"
          },
          {
            name                       = "deny-internet-inbound"
            priority                   = 4096
            direction                  = "Inbound"
            access                     = "Deny"
            protocol                   = "*"
            source_port_range          = "*"
            destination_port_range     = "*"
            source_address_prefix      = "Internet"
            destination_address_prefix = "*"
          }
        ]
      }
    ] 
  }
}




common_tags = {
  ManagedBy   = "Terraform"
  Environment = "dev"
  Project     = "hub-spoke"
  Owner       = "Jorge Pinto"
}

spokes = {
  # ── Spoke 1: App ──────────────────────────────
  spoke1 = {
    resource_group_name = "rg-spoke-app"
    vnet_name           = "vnet-spoke-app"
    address_space       = "10.1.0.0/16"
    tags = {
      Workload = "app"
    }
    subnets = [
      {
        name             = "snet-frontend"
        address_prefixes = ["10.1.1.0/24"]
        nsg_rules        = []
      },
      {
        name             = "snet-backend"
        address_prefixes = ["10.1.2.0/24"]
        nsg_rules        = []
      }
    ]
  }

/*
  # ── Spoke 2: Data ──────────────────────────────
  spoke2 = {
    resource_group_name = "rg-spoke-data"
    vnet_name           = "vnet-spoke-data"
    address_space       = "10.2.0.0/16"
    tags = {
      Workload = "data"
    }
    subnets = [
      {
        name             = "snet-databases"
        address_prefixes = ["10.2.1.0/24"]
        nsg_rules        = []
      },
      {
        name             = "snet-analytics"
        address_prefixes = ["10.2.2.0/24"]
        nsg_rules        = []
      }
    ]
  }

  # ── Spoke 3: compute- storage - kubernets ───────────────────
  spoke3 = {
    resource_group_name = "rg-spoke-compute"
    vnet_name           = "vnet-spoke-compute"
    address_space       = "10.3.0.0/16"
    tags = {
      Workload = "shared"
    }
    subnets = [
      {
        name             = "snet-compute"
        address_prefixes = ["10.3.1.0/24"]
        nsg_rules = [
          {
            name                       = "allow-backend-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "22"
            source_address_prefix      = "85.241.235.71/32"
            destination_address_prefix = "10.3.1.0/24"
          },
          {
            name                       = "deny-internet-inbound"
            priority                   = 4096
            direction                  = "Inbound"
            access                     = "Deny"
            protocol                   = "*"
            source_port_range          = "*"
            destination_port_range     = "*"
            source_address_prefix      = "Internet"
            destination_address_prefix = "*"
          }
        ]
      },
      
      {
        name             = "snet-storages"
        address_prefixes = ["10.3.2.0/24"]
        nsg_rules        = []
      },
      {
        name             = "snet-Kubernets"
        address_prefixes = ["10.3.3.0/24"]
        nsg_rules        = []
      }
    ]
  }

    # ── Spoke 4: Shared Services ───────────────────
  spoke4 = {
    resource_group_name = "rg-spoke-shared"
    vnet_name           = "vnet-spoke-shared"
    address_space       = "10.4.0.0/16"
    tags = {
      Workload = "shared"
    }
    subnets = [
      {
        name             = "snet-monitoring"
        address_prefixes = ["10.4.1.0/24"]
        nsg_rules        = []
      },
      {
        name             = "snet-devops"
        address_prefixes = ["10.4.2.0/24"]
        nsg_rules        = []
      }
    ]
  }
*/ 
}

