# Architecture Overview

## Design goals

Aligned with the Microsoft Well-Architected Framework's five pillars:
Reliability, Security, Cost Optimization, Operational Excellence, Performance Efficiency.

## Component decisions

| Decision | Choice | Why | Alternative considered |
|---|---|---|---|
| Compute | AKS | Container orchestration, autoscaling, industry standard | App Service (simpler but less portfolio depth) |
| Edge | Front Door Premium | Managed WAF rulesets + bot protection + CDN in one service | App Gateway (regional only, no CDN) |
| Hybrid connectivity | S2S VPN | Encrypted, realistic enterprise pattern, works from a home lab | ExpressRoute (cost-prohibitive for a lab) |
| Database location | On-premises | Simulates data residency requirements common in DACH enterprises | Azure SQL (loses the hybrid story) |
| Secrets | Key Vault + CSI driver | Pods mount secrets at runtime; nothing in Git or images | K8s secrets only (base64, weaker story) |
| IaC | Terraform | Multi-cloud skill, module ecosystem, remote state | Bicep (Azure-native but narrower job market value) |

## Network design (hub model)

```
vnet-hub 10.10.0.0/16
├── GatewaySubnet          10.10.0.0/27   VPN Gateway
├── snet-aks               10.10.1.0/24   AKS nodes + pods (NSG attached)
├── AzureBastionSubnet     10.10.2.0/27   Bastion
├── snet-private-endpoints 10.10.3.0/24   Key Vault PE
└── AzureFirewallSubnet    10.10.4.0/26   Azure Firewall (prod only)

On-premises: 192.168.1.0/24 — Windows Server 2025 (AD DS, DNS, SQL, RRAS)
```

## Traffic paths

**User request:** Internet → Front Door (WAF, TLS) → AKS ingress → pod →
Key Vault (secret via CSI, private endpoint) → VPN tunnel → SQL Server 1433.

**Telemetry:** pods + nodes → Container Insights → Log Analytics;
app → Application Insights; Windows Server → Azure Arc → Log Analytics → Sentinel.

## Environment differences

| Setting | dev | prod |
|---|---|---|
| VPN Gateway | VpnGw1 | VpnGw2 |
| AKS nodes | 1 (+spot 0-3) | 3-10 |
| Azure Firewall | off | on |
| Site Recovery | off | on |
| Log retention | 30 days | 90 days |
| Budget alert | €50 | €500 |
