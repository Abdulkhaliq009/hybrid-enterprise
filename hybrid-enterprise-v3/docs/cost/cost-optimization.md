# Cost Optimization Playbook

## Implemented in this repo

| Technique | Where | Saving |
|---|---|---|
| Environment sizing | environments/dev vs prod flags | Firewall + ASR off in dev: -€1.20/hr |
| Spot node pool | modules/aks (enable_spot_pool) | Up to 90% on burst compute |
| Cluster autoscaler | min 1 node in dev | Pay for load, not for idle |
| Log Analytics daily cap | 1 GB/day in dev | Prevents runaway ingestion bills |
| Log retention tiers | 30d dev / 90d prod | Retention is a real cost lever |
| Storage lifecycle | costmanagement module | Hot→Cool 30d→Archive 90d→delete 365d |
| LRS in dev, GRS in prod | backup + archive storage | Redundancy where it matters |
| Budget alerts | 80% + 100% thresholds | No surprise invoices |
| Nightly scale-to-zero | 07-auto-shutdown.ps1 runbook | ~60% on AKS compute |
| Resource tagging | enforced by Azure Policy | Cost allocation per project/env |

## Decision framework

1. **Turn it off** — the cheapest resource is a destroyed one. Lab sessions
   should end with terraform destroy.
2. **Right-size before reserving** — reservations lock in a size; fix sizing first.
3. **Reserve what survives** — 1-year reserved B2s saves ~40% but only makes
   sense for the always-on prod baseline, never for dev.
4. **Watch ingestion, not just compute** — Log Analytics and Firewall logs can
   quietly out-cost the VMs they monitor.

## What a real enterprise would add

- Azure Hybrid Benefit for Windows Server licenses
- Savings Plans across the subscription
- FinOps tagging taxonomy (cost-center, app-id) beyond this lab's four tags
