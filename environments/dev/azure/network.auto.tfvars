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
/* Instruções NSG
protocol                   = "Tcp" Pode ser ou tcp, ou UDP ou ICMPv4 ou ICMPv6 ou Any

Todas as demais variaves pode ser single ou multiples.AZURE_KEY_PUB = "Por exemplo "
source_port_range          = "*" apenas leva um valor, exemplo 80, ou *. O * só funciona neste modo single
source_port_ranges <- s     = ["22", "443"] >- neste formato
IP's é igual
source_address_prefix      "85.241.235.71/32"
source_address_prefixes     = [
         "85.241.235.71/32", <- não esquecer a virgula
         "85.241.235.72/32"
            ]
Um mutiple pode ser single se la colocamos só um valor
source_address_prefixes     = ["85.241.235.71/32"]
         
*/
hubs = {
  hub1 ={
    hub_resource_group_name      = "QDG_network_dev_hub1"
    hub_vnet_name                = "vnet-hub"
    hub_address_space            = "10.1.0.0/16"
    tags = {
      Workload = "app"
    }
    subnets = [
      {
        name             = "GatewaySubnet"
       address_prefixes = ["10.1.0.0/27"]
       nsg_rules        = [] # Não suporta NSG — obrigatório estar vazio
      },
      {
        name             = "AzureFirewallSubnet"
        address_prefixes = ["10.1.1.0/26"]
        nsg_rules        = [] # Não suporta NSG — obrigatório estar vazio
      },
      {
        name             = "snet-NVA"
        address_prefixes = ["10.1.2.0/24"]
        nsg_rules = [
          {
            name                       = "allow-ssh-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*" # usar * (any) só em single
            destination_port_ranges     = ["22", "443", "80"]
            source_address_prefixes     = [
                "85.241.235.71/32",
                "85.241.235.72/32"
            ]
            destination_address_prefix = "10.1.2.0/24"

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
        udr_routes = [
          {
            name                   = "route-to-firewall"
            address_prefix         = "0.0.0.0/0"
            next_hop_type          = "VirtualAppliance"
            next_hop_in_ip_address = "10.1.2.4"
          },
          {
            name           = "route-to-onprem"
            address_prefix = "192.168.0.0/16"
            next_hop_type  = "VirtualNetworkGateway"
          }
        ]
      }
    ] 
  }
    hub2 ={
    hub_resource_group_name      = "QDG_network_dev_hub2"
    hub_vnet_name                = "vnet-hub"
    hub_address_space            = "10.2.0.0/16"
    tags = {
      Workload = "app"
    }
    subnets = [
      {
        name             = "GatewaySubnet"
       address_prefixes = ["10.2.0.0/27"]
       nsg_rules        = [] # Não suporta NSG — obrigatório estar vazio
      },
      {
        name             = "AzureFirewallSubnet"
        address_prefixes = ["10.2.1.0/26"]
        nsg_rules        = [] # Não suporta NSG — obrigatório estar vazio
      },
      {
        name             = "snet-NVA"
        address_prefixes = ["10.2.2.0/24"]
        nsg_rules = [
          {
            name                       = "allow-ssh-inbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_ranges          =["80"] 
            destination_port_ranges     = ["22", "443"]
             source_address_prefixes     = [
                "85.241.235.71/32",
              ]
            destination_address_prefixes = [
                "10.2.2.4/32", 
                "10.2.2.5/32"
              ]
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
    address_space       = "10.100.0.0/16"
    tags = {
      Workload = "app"
    }
    subnets = [
      {
        name             = "snet-app"
        address_prefixes = ["10.100.1.0/24"]
        nsg_rules        = []
      },
      {
        name             = "snet-data"
        address_prefixes = ["10.100.2.0/24"]
        nsg_rules        = []
      }
    ]
  }


  # ── Spoke 2: Data ──────────────────────────────
  /*
  spoke2 = {
    hub = "hub2"
    resource_group_name = "rg-spoke-data"
    vnet_name           = "vnet-spoke-data"
    address_space       = "10.200.0.0/16"
    tags = {
      Workload = "data"
    }
    subnets = [
      {
        name             = "snet-databases"
        address_prefixes = ["10.200.1.0/24"]
        nsg_rules        = []
      },
      {
        name             = "snet-analytics"
        address_prefixes = ["10.2.200.0/24"]
        nsg_rules        = []
      }
    ]
  }
  */
  # ── Spoke 3: compute- storage - kubernets ───────────────────
  
  spoke3 = {
    hub = "hub2"
    resource_group_name = "rg-spoke-compute"
    vnet_name           = "vnet-spoke-compute"
    address_space       = "10.200.0.0/16"
    tags = {
      Workload = "shared"
    }
    subnets = [
      {
        name             = "snet-compute"
        address_prefixes = ["10.200.1.0/24"]
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
            destination_address_prefix = "10.200.1.0/24"
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
        address_prefixes = ["10.200.2.0/24"]
        nsg_rules        = []
      },
      {
        name             = "snet-Kubernets"
        address_prefixes = ["10.200.3.0/24"]
        nsg_rules        = []
      }
    ]
  }

  # ── Spoke 4: Shared Services ───────────────────
  /*
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
*/
}

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
  hub_to_spoke_allow_virtual_network_access = true
  
  #Permite tráfego que foi roteado por um appliance (firewall, NVA). Usado quando tens firewalls, Azure Firewall, appliances virtuais
  hub_to_spoke_allow_forwarded_traffic      = true
  
  #Permite que a VNet local ofereça o seu gateway VPN/ExpressRoute à outra VNet. True do lado do HUB
  hub_to_spoke_allow_gateway_transit        = true
  
  #Permite que a VNet local use o gateway da VNet remota. Só pode ser usada de um dos lados como true, clarament do lado oda spokes.
  hub_to_spoke_use_remote_gateways          = false

# ────────VNET_PEERINGS HUB-to-SPOKE ─────────────────────────────────
 # Spoke → Hub
  #Permite tráfego entre VNets. normalmente true
  spoke_to_hub_allow_virtual_network_access = true
  
  #Permite tráfego que foi roteado por um appliance (firewall, NVA). Usado quando tens firewalls, Azure Firewall, appliances virtuais
  spoke_to_hub_allow_forwarded_traffic      = true
  
  #Permite que a VNet local ofereça o seu gateway VPN/ExpressRoute à outra VNet. True do lado do HUB
  spoke_to_hub_allow_gateway_transit        = false
  
  #Permite que a VNet local use o gateway da VNet remota. Só pode ser usada de um dos lados como true, clarament do lado oda spokes.
  spoke_to_hub_use_remote_gateways          = false
  
