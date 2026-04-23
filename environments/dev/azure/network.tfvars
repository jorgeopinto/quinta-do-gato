location                     = "westeurope"

common_tags = {
  ManagedBy   = "Terraform"
  Environment = "dev"
  Project     = "hub-spoke"
  Owner       = "Jorge Pinto"
}

# ─────────────────────────────────────────
# HUB VNets (dynamic using variables)
# ─────────────────────────────────────────


hubs = {
  hub1 ={
    hub_resource_group_name      = "QDG_network_dev"
    hub_vnet_name                = "vnet-hub"
    hub_address_space            = "10.0.0.0/16"
    tags = {
      Workload = "app"
    }
    subnets = [
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



# ─────────────────────────────────────────
# Spoke VNets (dynamic using variables)
# ─────────────────────────────────────────

spokes = {
  
  # ── Spoke 1: App ──────────────────────────────
  
  spoke1 = {
    hub = "hub1"
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


  # ── Spoke 2: Data ──────────────────────────────
  spoke2 = {
    hub = "hub1"
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
  /*
  spoke3 = {
    hub = "hub1"
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
    hub = "hub1"
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

}
*/
# ─────────────────────────────────────────────────────
# Vnet Peerings
# Static. advertizement routes from a gateway
# can be controled using a UDR associated to a subnet 
# enabeling BGP block flag
# use remote gatewa only can be true if exists a EXR or VPN GW
# ─────────────────────────────────────────────────────

# ────────VNET_PEERINGS HUB-to-SPOKE ─────────────────────────────────
 # Hub → Spoke
  #Permite tráfego entre VNets. normalmente true
  HUB-TO-SPOKE-allow_virtual_network_access = true
  
  #Permite tráfego que foi roteado por um appliance (firewall, NVA). Usado quando tens firewalls, Azure Firewall, appliances virtuais
  HUB-TO-SPOKE-allow_forwarded_traffic      = true
  
  #Permite que a VNet local ofereça o seu gateway VPN/ExpressRoute à outra VNet. True do lado do HUB
  HUB-TO-SPOKE-allow_gateway_transit        = true
  
  #Permite que a VNet local use o gateway da VNet remota. Só pode ser usada de um dos lados como true, clarament do lado oda spokes.
  HUB-TO-SPOKE-use_remote_gateways          = false

# ────────VNET_PEERINGS HUB-to-SPOKE ─────────────────────────────────
 # Spoke → Hub
  #Permite tráfego entre VNets. normalmente true
  SPOKE-TO-HUB-allow_virtual_network_access = true
  
  #Permite tráfego que foi roteado por um appliance (firewall, NVA). Usado quando tens firewalls, Azure Firewall, appliances virtuais
  SPOKE-TO-HUB-allow_forwarded_traffic      = true
  
  #Permite que a VNet local ofereça o seu gateway VPN/ExpressRoute à outra VNet. True do lado do HUB
  SPOKE-TO-HUB-allow_gateway_transit        = false
  
  #Permite que a VNet local use o gateway da VNet remota. Só pode ser usada de um dos lados como true, clarament do lado oda spokes.
  SPOKE-TO-HUB-use_remote_gateways          = false
  
