# Hub and Spoke com Terraform — Azure Modules

## Arquitectura

> É possível ter mais do que um HUB VNet.

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

## Estrutura de Ficheiros

```
environments/dev/azure/
├── main.tf                  # Topologia principal
├── variables.tf             # Variáveis raiz
├── outputs.tf               # Outputs raiz
├── network.auto.tfvars      # Variáveis para construção da rede
└── compute.auto.tfvars      # Variáveis para criação e integração com a rede

modules/azure/
├── network/                 # Módulo de rede — VNet, Subnets e NSGs
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vnet_peering/        # Módulo de peering bidirecional
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── nsg/                 # Módulo de Network Security Groups
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
└── compute/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

---

## Pré-requisitos

- Terraform >= 1.5.0
- Azure CLI autenticado (`az login`)
- Permissões de **Contributor** na subscrição

---

## Como Utilizar

### 1. Inicializar

```bash
terraform init
```

### 2. Planear

```bash
terraform plan -out plan.out
```

### 3. Aplicar

```bash
terraform apply plan.out
```

### 4. Destruir (se necessário)

```bash
terraform destroy
```

---

## Configuração Avançada

### Adicionar um novo HUB

Em `network.auto.tfvars`, adiciona uma nova entrada no mapa `hubs`:

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

### Adicionar um novo Spoke e associar a um HUB

Em `network.auto.tfvars`, adiciona uma nova entrada no mapa `spokes` e indica o HUB de destino:

```hcl
spokes = {
  # ... spokes existentes ...

  spoke4 = {
    hub                 = "hub1"  # <-- indica a qual HUB se liga
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

### Aplicar NSGs a subnets (HUB ou Spoke)

Em `network.auto.tfvars`, adiciona `nsg_rules` à subnet desejada:
NOTA: abaixo tem exemplo para modo unicom, ou seja uma porta src ou des, uma range IP's src dest, no entanto está adaptado a multi se alterar para plural com a seguintge estrotura
```hcl
source_address_prefixes     = [
         "1.2.3.4/32", <- não esquecer a virgula
         "5.6.7.8/32"
            ]
```
Aplicavel em:
source_port_ranges
destination_port_ranges
source_address_prefixes
destination_address_prefixes

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

### Peering entre Spokes e HUBs

Os peerings são criados automaticamente via `for_each`. As configurações de cada lado do peering podem ser definidas individualmente.

---

### Activar VPN Gateway Transit

Se existir um VPN Gateway no HUB, activa as seguintes opções em `network.auto.tfvars`:

```hcl
hub_to_spoke_allow_gateway_transit = true
hub_to_spoke_use_remote_gateways   = false
```

> **Nota:** O VPN Gateway tem de ser criado antes de activar estas opções. A configuração de peering aplica-se a todos os spokes.  
> Se não quiseres usar as rotas provenientes do VPN ou ExpressRoute Gateway, podes usar uma UDR com a flag de propagação de rotas BGP desactivada.

---

## Outputs Disponíveis

| Output              | Descrição                          |
|---------------------|------------------------------------|
| `hub_vnet_id`       | ID da VNet Hub                     |
| `hub_subnet_ids`    | IDs das subnets do Hub             |
| `spoke_vnet_ids`    | IDs das VNets Spoke                |
| `spoke_subnet_ids`  | IDs das subnets por Spoke          |
| `peering_ids`       | IDs dos peerings Hub ↔ Spoke       |
