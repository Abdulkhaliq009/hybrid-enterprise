# Architecture Decision Records (ADR)

## ADR-001: AKS over App Service

**Status:** Accepted
**Context:** Need a compute layer for the Node.js API.
**Decision:** AKS with a system pool + optional spot pool.
**Consequences:** More operational complexity (upgrades, node management) in
exchange for Kubernetes skills demonstration, network policies, PDB, HPA, and
per-pod security contexts. App Service remains the right answer for teams
without K8s skills — documented in interview Q&A.

## ADR-002: On-premises SQL Server as system of record

**Status:** Accepted
**Context:** Many German enterprises keep regulated data on-premises.
**Decision:** SQL Server on Windows Server 2025 reached only via S2S VPN.
**Consequences:** Latency (~10-30ms over tunnel) accepted; database HA is a
documented limitation of the lab (single node; production would use Always On).

## ADR-003: RBAC-mode Key Vault with CSI Secrets Store

**Status:** Accepted
**Context:** Pods need DB credentials without secrets in Git or images.
**Decision:** Key Vault RBAC authorization + AKS Key Vault CSI provider with
rotation enabled; access via the cluster's secrets-provider managed identity.
**Consequences:** Secret rotation propagates to mounted volumes automatically.

## ADR-004: Terraform with per-environment root modules

**Status:** Accepted
**Context:** Need dev and prod with different sizing but identical topology.
**Decision:** environments/dev and environments/prod call the same root module
with different variables; separate state files.
**Consequences:** Drift between environments is impossible by construction;
promoting a change = merging the module change.
