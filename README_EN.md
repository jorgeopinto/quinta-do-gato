# Hub and Spoke with Terraform — Azure Modules

## Architecture

> You can have more than one HUB VNet.

```
                    ┌─────────────────────────────┐
                    │         HUB VNet             │
                    │       10.0.0.0/16            │
                    │                              │
                    │  ┌──────────────────────┐    │
                    │  │  GatewaySubnet        │    │
                    │  │  10.0.0.0/27          │    │
                    │  ├──────────────────────┤    │
                    │  │  AzureFirewallSubnet  │    │
                    │  │  10.0.1.0/26          │    │
                    │  ├──────────────────────┤    │
                    │  │  snet-management      │    │
                    │  │  10.0.2.0/24          │    │
                    │  └──────────────────────┘    │
                    └──────────────────────────────┘
                       /           |           \
                 Peering        Peering       Peering
                  /               |               \
   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
   │  SPOKE App   │   │  SPOKE Data  │   │ SPOKE Shared │
   │ 10.1.0.0/16  │   │ 10.2.0.0/16  │   │ 10.3.0.0/16  │
   │              │   │              │   │              │
   │ snet-frontend│   │ snet-databases│  │ snet-monitor │
   │ snet-backend │   │ snet-analytics│  │ snet-devops  │
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
│   └── nsg/                 # Network Security Groups module
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── compute/
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

## Advanced Configuration

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

### Add a new Spoke and connect it to a HUB

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

### Apply NSGs to subnets (HUB or Spoke)

In `network.auto.tfvars`, add `nsg_rules` to the desired subnet:

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

---

### Peering between Spokes and HUBs

Peerings are automatically created via `for_each`. Settings for each side of the peering can be configured individually.

---

### Enable VPN Gateway Transit

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
