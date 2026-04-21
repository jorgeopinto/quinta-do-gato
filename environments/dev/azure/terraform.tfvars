location                     = "westeurope"
hub_resource_group_name      = "QDG_network_dev"
hub_vnet_name                = "vnet-hub"
hub_address_space            = "10.0.0.0/16"
hub_gateway_subnet_prefix    = "10.0.0.0/26"
hub_firewall_subnet_prefix   = "10.0.1.0/26"
hub_management_subnet_prefix = "10.0.2.0/24"
hub_nva_subnet_prefix= "10.0.3.0/24"
enable_gateway_transit       = true

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
      },
      {
        name             = "snet-backend"
        address_prefixes = ["10.1.2.0/24"]
      }
    ]
  }

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
      },
      {
        name             = "snet-analytics"
        address_prefixes = ["10.2.2.0/24"]
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
      },
      {
        name             = "snet-storages"
        address_prefixes = ["10.3.2.0/24"]
      },
      {
        name             = "snet-Kubernets"
        address_prefixes = ["10.3.3.0/24"]
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
      },
      {
        name             = "snet-devops"
        address_prefixes = ["10.4.2.0/24"]
      }
    ]
  }
 
}
