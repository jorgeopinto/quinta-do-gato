# Hub and Spoke with Terraform — Azure Modules

## Architecture

> You can have more than one HUB VNet.

```
                    ┌─────────────────────────────┐
                    │         HUB VNet            │
                    │       10.0.0.0/16           │
                    │                             │
                    │  ┌──────────────────────┐   │
                    │  │  GatewaySubnet       │   │
                    │  │  10.0.0.0/27         │   │
                    │  ├──────────────────────┤   │
                    │  │  AzureFirewallSubnet │   │
                    │  │  10.0.1.0/26         │   │
                    │  ├──────────────────────┤   │
                    │  │  snet-management     │   │
                    │  │  10.0.2.0/24         │   │
                    │  └──────────────────────┘   │
                    └─────────────────────────────┘
                       /           |           \
                 Peering        Peering       Peering
                  /               |               \
   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
   │  SPOKE App   │   │  SPOKE Data  │   │ SPOKE Shared │
   │ 10.1.0.0/16  │   │ 10.2.0.0/16  │   │ 10.3.0.0/16  │
   │              │   │              │   │              │
   │ snet-frontend│   │snet-databases│   │ snet-monitor │
   │ snet-backend │   │snet-analytics│   │ snet-devops  │
   └──────────────┘   └──────────────┘   └──────────────┘
```

---

## File Structure

```
environments/dev/azure/
├── main.tf                  # Main topology
├── variables.tf             # Root variables
├── outputs.tf               # Root outputs
├── network.auto.tfvars      # Variables for building the network structure
└── compute.auto.tfvars      # Variables for compute creation and network integration

modules/azure/
├── network/                 # Network module — VNet, Subnets and NSGs
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vnet_peering/        # Bidirectional peering module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── nsg/                 # Network Security Groups module
│   |   ├── main.tf
│   |   ├── variables.tf
│   |   └── outputs.tf
|   └── udr/                 # Route table Module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── compute/
|   ├── main.tf
|   ├── variables.tf
|   └── outputs.tf
└── vpn/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf

```

---

## Prerequisites

- Terraform >= 1.5.0
- Azure CLI authenticated (`az login`)
- **Contributor** permissions on the subscription

---

## How to Use

### 1. Initialise

```bash
terraform init
```

### 2. Plan

```bash
terraform plan -out plan.out
```

### 3. Apply

```bash
terraform apply plan.out
```

### 4. Destroy (if needed)

```bash
terraform destroy
```

---

## configurations: We only need to use X.AUTO.TFVARS files to build our network and add resources.

### Add a new HUB

In `network.auto.tfvars`, add a new entry to the `hubs` map:

```hcl
hubs = {
  hub2 = {
    hub_resource_group_name = "QDG_network_dev_hub2"
    hub_vnet_name           = "vnet-hub2"
    hub_address_space       = "10.2.0.0/16"
    # ...
  }
}
```

---

### Add a new Spoke and connect it to a HUB -> network.auto.tfvars

In `network.auto.tfvars`, add a new entry to the `spokes` map and specify the target HUB:

```hcl
spokes = {
  # ... existing spokes ...

  spoke4 = {
    hub                 = "hub1"  # <-- specify which HUB to connect to
    resource_group_name = "rg-spoke-security"
    vnet_name           = "vnet-spoke-security"
    address_space       = "10.4.0.0/16"
    tags = {
      Workload = "security"
    }
    subnets = [
      {
        name             = "snet-waf"
        address_prefixes = ["10.4.1.0/24"]
      }
    ]
  }
}
```

---

### Apply NSGs to subnets (HUB or Spoke) -> network.auto.tfvars

In `network.auto.tfvars`, add `nsg_rules` to the desired subnet:\Note: below is an example for single mode, meaning one source or destination port, one source/destination IP range; however, it is adapted to multi if changed to plural using the following structure.

```hcl
source_address_prefixes     = [
         "1.2.3.4/32", <- não esquecer a virgula
         "5.6.7.8/32"
            ]
```
applyed to:\
source_port_ranges\
destination_port_ranges\
source_address_prefixes\
destination_address_prefixes\

```hcl
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
        destination_address_prefix = "10.3.1.0/24"
      },
      # ...
    ]
  }
]
```
### Applying UDRs to subnets (HUB or Spoke) -> network.auto.tfvars

In `network.auto.tfvars`, add `nsg_rules` to the desired subnet.\
Similarly to NSG, it is placed inside the subnet we want to associate, which in turn sits inside the HUB or SPOKE VNet.\
There is only one additional parameter, propagate_gateway_routes, which is of importance.\ 

```hcl
subnets = [
  {
    name             = "snet-compute"
    address_prefixes = ["10.200.1.0/24"]
    nsg_rules = []
    propagate_gateway_routes = true  # NÃO propagar rotas do gateway. Só letra minuscula
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
```
UDR Instructions:

propagate_gateway_routes, which sits outside the block, defaults to "true", so it wouldn't even be necessary if we want to receive routes coming from on-premises via VPN or ExpressRoute. However, for consistency, it should always accompany the udr_routes block.\
When set to "false", we do not want to receive routes from on-premises. This option is important for maintaining consistency in peerings — we can set all of them to "use remote gateway", for example.

There are 5 types of next HOP:

VirtualNetworkGateway → Sends traffic to the Gateway, towards on-premises (VPN Gateway or ExpressRoute Gateway)\
VirtualAppliance → Points to an appliance (NVA), firewall, and is the only one that requires next_hop_in_ip_address = IP\
Internet → Points to 0.0.0.0/0, but be careful here because the address_prefix (destination range) must be public. This does not perform NAT\
VirtualNetwork → Traffic should be routed internally, within the VNet itself. Forces traffic to stay inside the VNet. Azure already does this by default.\
none → There is no next-hop. Discards the traffic

---

### Peering between Spokes and HUBs -> network.auto.tfvars

Peerings are automatically created via `for_each`. Settings for each side of the peering can be configured individually.

---

### Enable VPN Gateway Transit -> network.auto.tfvars

If a VPN Gateway exists in the HUB, enable the following options in `network.auto.tfvars`:

```hcl
hub_to_spoke_allow_gateway_transit = true
hub_to_spoke_use_remote_gateways   = false
```

> **Note:** The VPN Gateway must be created before enabling these options. The peering configuration applies to all spokes.  
> If you do not want to use routes from the VPN or ExpressRoute Gateway, you can use a UDR with the BGP route propagation flag disabled.

---

## Available Outputs

| Output              | Description                        |
|---------------------|------------------------------------|
| `hub_vnet_id`       | Hub VNet ID                        |
| `hub_subnet_ids`    | Hub subnet IDs                     |
| `spoke_vnet_ids`    | Spoke VNet IDs                     |
| `spoke_subnet_ids`  | Spoke subnet IDs per Spoke         |
| `peering_ids`       | Hub ↔ Spoke peering IDs            |

## COMPUTE -> compute.auto.tfvars
In this file we add virtual machines ‘LINUX ONLY’ and decide which HUB/SPOKE they will belong to and the subnet, for example:\
I will add a VM to VNet HUB1 in the subnet ‘snet-NVA’

```hcl
hub_virtual_machines = {
  # "hub1" deve corresponder à key do teu map `hubs`
  hub1 = {
    "vm-mgmt" = {
      name           = "vm-hub1-mgmt"
      count          = 1 #Reducing the count will ALWAYS destroy resources and recreate them.
      #Adding works fine and does not cause destruction.
      # To avoid destruction, you must use stable keys instead of count.
      vm_size        = "Standard_D2s_v3"
      subnet_name    = "snet-NVA"   # Exact name of the subnet defined in the hubs.
      os_disk_type   = "Standard_LRS"
      os_disk_size_gb = 30
      # The image is optional; if not specified, it uses Ubuntu 24.04 LTS by default as defined in the module variables.

      #ssh_public_key -> It is already injected into the TF_VAR in GitHub.
      admin_username = "jorge"
    }
  }
}
```
The mode with stable keys will be added to a non-public repository.\
Using count is better for creating VMs in bulk, for example 100, and there’s no issue adding more. Reducing the number of VMs should be avoided because it destroys and recreates the others.

```hcl
spoke_virtual_machines = {
  # spoke1’ must match the key in your spokes map
  
  spoke1 = {
    "vm-app" = {
      name           = "vm-spoke1-app"
      count          = 1 
      vm_size        = "Standard_D2s_v3"
      subnet_name    = "snet-data"          # Exact name of the subnet defined in the spokes.
      (...)
    }
  }
```
## VPN -> vpn.auto.tfvars
In this file we add VPNs to the Hubs. It’s designed only for route‑based VPNs (which makes more sense to me), and based on the infrastructure defined in network.tfvars we choose which Hub we want the VPN to belong to. It will automatically be placed in the subnet dedicated to VPNs.\

We can enable or disable the VPN, choose whether to use BGP or not, set it as Active‑Passive or Active‑Active, configure the Phase I (IKE) and Phase II (IPsec) parameters, and of course, for a VPN Gateway, define as many remote sites as we need.\ 

```hcl
vpn_s2s = {
  hub1 = {  -----> choose the HUB
    enabled              = false ----> have VPN or NOT
    (...)
    active_active        = false -----> A-A ou A-P 
    
    enable_bgp           = false -----> BGP or NOT
    
    (...)

    sku                  = "VpnGw1AZ"
    
    (...)
    
    # Vários sites on‑prem
    sites = {
      Lisboa = { ---> for a on-premisses site
        
            (...)
        ipsec_policy = { -> choose PH1 and PHII settings
      # --- Phase 1 (IKE) ---
          ike_encryption   = "AES256"
          ike_integrity    = "SHA256"
          dh_group         = "DHGroup14"

      # --- Phase 2 (IPsec) ---
          ipsec_encryption = "AES256"
          ipsec_integrity  = "SHA256"
          pfs_group        = "None"

      (...)    
    } 
      }
/*
      Porto = { -------> for another ON-premisses site
        onprem_public_ip     = "90.10.10.10"
        onprem_address_space = [
          "10.10.0.0/24"
        ]
        onprem_bgp_asn        = 65002
        onprem_bgp_peer_ip    = "10.10.0.1"
        
        


      # Sem ipsec_policy = use Azure defaults
        ipsec_policy = null  -----> If choose in this way, will configure Azure defaults

      }
*/
    }  
  }
}
```

## For the public repository, this is it… The private one has more stuff in it 🙂