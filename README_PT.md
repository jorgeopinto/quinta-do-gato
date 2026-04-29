# Hub and Spoke com Terraform — Azure Modules

## Arquitectura

> É possível ter mais do que um HUB VNet.

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
│   ├── nsg/                 # Módulo de Network Security Groups
│   |   ├── main.tf
│   |   ├── variables.tf
│   |   └── outputs.tf
|   └── udr/                 # Módulo para route tables
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

## Configurações ->  APENAS NECESSITAMOS DE USAR FICHEIROS X.AUTO.TFVARS PARA CONTRUIR A NOSSA REDE E ADICIONAR RECURSOS

### Adicionar um novo HUB -> network.auto.tfvars

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

### Adicionar um novo Spoke e associar a um HUB -> network.auto.tfvars

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

### Aplicar NSGs a subnets (HUB ou Spoke) -> network.auto.tfvars

Em `network.auto.tfvars`, adiciona `nsg_rules` à subnet desejada:
NOTA: abaixo tem exemplo para modo unico, ou seja uma porta src ou dest, uma range IP's src dest, no entanto está adaptado a multi se alterar para plural com a seguintge estrutura
```hcl
source_address_prefixes     = [
         "1.2.3.4/32", <- não esquecer a virgula
         "5.6.7.8/32"
            ]
```
Aplicavel em:\
source_port_ranges\
destination_port_ranges\
source_address_prefixes\
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
### Aplicar UDRs a subnets (HUB ou Spoke) -> network.auto.tfvars

Em `network.auto.tfvars`, adiciona `nsg_rules` à subnet desejada.\
À semelhança de NSG é colocado dentro da subnet que que queremos associar, que por sua vez vem dentro do HUB ou SPOKE.\
apenas existe mais um parametro propagate_gateway_routes que tem importancia. 

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

Instruçoes UDR: 

propagate_gateway_routes udr_routes que vem fora do bloco  por defeito é sempre "true", portanto nem era necessario se queremos receber as rotas que veem de on-premises por VPN ou EXR, no entanto por uma questão de consistencia, deverá ser sempre acompanha o bloco udr_routes\
Quando é "false" não queremos receber rotas do on-premises. Esta opção é importante para manter consitencia nos peerings. Podemos colocar todos como "use remote gateway", por exemplo.

Existem 5 tipos de next HOP:\
VirtualMetworkGateway -> Enviar o tráfego para o Gateway, para on-premisses (VPN Gateway ou ExpressRoute Gateway)\
VirtualAppliance -> aponta para um appliance (NVA), firewall, e é o unico que necessita next_hop_in_ip_address = IP\
Internet -> aponta para 0.0.0.0/0, mas cuidado aqui porque o address_prefix (range destino) tem de ser publico. Isto nao faz NAT\
VirtualNetwork -> O trafego  deve ser encaminhado internamente, dentro da propria vnet. Força o tráfego fique dentro da VNet. Azure j´faz isso por defeito.\
none -> Não há next-hop. Descarta o tráfego\

---

### Peering entre Spokes e HUBs ->  network.auto.tfvars

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

---

## COMPUTE -> compute.auto.tfvars
Neste ficheiro adicionamos virtual machines "APENAS LINUX" e decidimos a que HUB/SPOKE vai pertencer e a Subnet como por exemplo:\
Vou adicionar um vma a Vnet HUB1 na subnet "snet-NVA

```hcl
hub_virtual_machines = {
  # "hub1" deve corresponder à key do teu map `hubs`
  hub1 = {
    "vm-mgmt" = {
      name           = "vm-hub1-mgmt"
      count          = 1 #reduzir o count vai SEMPRE destruir recursos e recriar.
      #adicionar funciona bem e não causa destruições
      # evitar destruições, tem de se usar keys estáveis e não count
      vm_size        = "Standard_D2s_v3"
      subnet_name    = "snet-NVA"   # nome exato do subnet definido nos hubs
      os_disk_type   = "Standard_LRS"
      os_disk_size_gb = 30
      # image é opcional; não existindo usa Ubuntu 24.04 LTS por defeito declarado nas variaveis do modulo

      #ssh_public_key -> já é injectado no TF_VAR do github
      admin_username = "jorge"
    }
  }
}
```
O modo com keys estáveis vai ser adicionado a um repositorio não publco.\ 
Com count é melhor para criar Vm's em massa, por exemplo 100, e nao há problema em acrescentar. Reduzir o numero de vms é evitavel porque destroy e recria as outras.\

Para VMs em Spoke o bloco de codigo é semelhante

```hcl
spoke_virtual_machines = {
  # "spoke1" deve corresponder à key do teu map `spokes`
  
  spoke1 = {
    "vm-app" = {
      name           = "vm-spoke1-app"
      count          = 1 
      vm_size        = "Standard_D2s_v3"
      subnet_name    = "snet-data"          # nome exato do subnet definido nos spokes
      (...)
    }
  }
```
