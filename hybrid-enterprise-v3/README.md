# Hybrid Enterprise Cloud Platform

Production-grade hybrid cloud lab aligned with the Microsoft Well-Architected Framework:
**Reliability · Security · Cost Optimization · Operational Excellence · Performance Efficiency**

Azure (Front Door, AKS, Key Vault, Sentinel) connected to on-premises Windows Server 2025
(AD DS, DNS, SQL Server, RRAS) via Site-to-Site VPN. Everything as code.

## Architecture

```
                     INTERNET
                        │
              ┌─────────▼─────────┐
              │  Azure Front Door  │  CDN + WAF + TLS
              └─────────┬─────────┘
                        │
              ┌─────────▼─────────┐
              │        AKS         │  Node.js API · Helm · HPA · Ingress
              └─────────┬─────────┘
          ┌─────────────┼─────────────┐
          ▼             ▼             ▼
      Key Vault        ACR       Observability
     (Managed ID)              (Prometheus·Grafana·App Insights)
                        │
              ┌─────────▼─────────┐
              │    VPN Gateway     │  IPSec S2S
              └─────────┬─────────┘
                        │ encrypted tunnel
              ┌─────────▼─────────┐
              │ Windows Server 25  │  AD DS · DNS · SQL · RRAS · Azure Arc
              └───────────────────┘
```

## The five pillars in this repo

| Pillar | Implementation |
|---|---|
| Reliability | AKS multi-replica + PDB, Azure Backup, Site Recovery, tested DR failover (RPO 15min / RTO 1h) |
| Security | Entra ID + RBAC, Managed Identity, Key Vault, private endpoints, NSGs, Azure Firewall, Sentinel SIEM |
| Cost Optimization | Budgets + alerts, spot nodes, auto-shutdown schedules, storage lifecycle, docs/cost/ |
| Operational Excellence | DevSecOps pipeline with quality gates, tests/, runbooks, troubleshooting guides |
| Performance Efficiency | HPA autoscaling, CDN caching, resource limits, load testing docs |

## Repository map

```
hybrid-enterprise/
├── .github/            CI/CD workflows, CODEOWNERS, dependabot
├── app/                Node.js API + unit tests + Dockerfile
├── helm/hybrid-api/    Full chart: Deployment, Service, Ingress, HPA, PDB, NetworkPolicy
├── infra/
│   ├── terraform/      14 modules + dev/prod environments
│   └── onprem/         7 PowerShell scripts (SQL, VPN, Arc, DSC)
├── tests/              Infrastructure, networking, security, k8s, app, DR tests
├── docs/               11 documentation areas including interview prep
├── diagrams/           Architecture diagrams
└── scripts/            Helper scripts
```

## Quick start

```bash
# 1. Deploy Azure infrastructure (dev environment)
cd infra/terraform/environments/dev
terraform init && terraform apply

# 2. Configure on-premises (run on Windows Server 2025 as Administrator)
infra/onprem/01-install-sql.ps1
infra/onprem/02-configure-vpn.ps1 -AzureVpnGatewayIp <from terraform output>
infra/onprem/03-firewall-rules.ps1
infra/onprem/04-create-db-user.ps1
infra/onprem/05-arc-agent.ps1
infra/onprem/06-dsc-config.ps1

# 3. Deploy the app
az aks get-credentials --resource-group rg-hybrid-dev --name aks-hybrid-dev
helm upgrade --install hybrid-api ./helm/hybrid-api

# 4. Run the test suite
./tests/run-all.sh
```

## Documentation index

| Area | Path |
|---|---|
| Architecture decisions | docs/architecture/ |
| Sentinel KQL detections | docs/security/sentinel/ |
| Monitoring stack | docs/monitoring/ |
| DR strategy + failover test | docs/disaster-recovery/ |
| DevSecOps pipeline | docs/devsecops/ |
| Cost breakdown + optimization | docs/cost/ |
| Day-2 operations | docs/operations/ |
| Troubleshooting scenarios | docs/troubleshooting/ |
| **Interview Q&A** | docs/interview/ |

## Known limitations (Azure for Students)

| Feature | Status | Notes |
|---|---|---|
| Azure Front Door Premium | Code written, not deployed | Student subscription blocks Front Door. Module `modules/frontdoor` is complete with WAF policy (OWASP 2.1 + Bot Manager 1.0). Deploy on a paid subscription with one variable change. |
| Microsoft Sentinel | Code written, not deployed | Poland Central region doesn't support Sentinel. Module `modules/sentinel` has 4 KQL detection rules. Works in westeurope/eastus. |
| Azure Firewall | Disabled in dev | Cost ~€1.15/hr. Enabled in prod environment config. NSGs provide the equivalent perimeter control in dev. |
| GRS storage | Replaced with LRS | GRS not supported in Poland Central. Production would use GRS or RA-GRS. |

These are subscription and region constraints, not design gaps. The Terraform code for all features is in the repo and documented.

## Author

Abdul Khaliq — Systemadministrator / Junior Cloud Engineer
LinkedIn: linkedin.com/in/khaliqabdul24 · GitHub: Abdulkhaliq009
