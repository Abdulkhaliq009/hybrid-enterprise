# Kubernetes Workload Design

## Everything the deployment carries and why

| Resource | Purpose | Interview one-liner |
|---|---|---|
| Deployment (2 replicas) | Availability during node loss and rollouts | "One replica is an outage waiting to happen" |
| HPA (2-10, 70% CPU) | Handle load spikes without paying for idle | "Scale on demand, not on fear" |
| PodDisruptionBudget | minAvailable:1 blocks voluntary evictions from killing all pods | "Protects availability during node drains and upgrades" |
| NetworkPolicy | Egress: only on-prem:1433, DNS, 443 | "A compromised pod can't scan the network" |
| Liveness probe | /health — restart wedged processes | |
| Readiness probe | /health — don't route to unready pods | /ready (DB check) deliberately NOT used for readiness: a DB outage shouldn't remove all pods from the LB |
| Resource requests/limits | 100m-500m CPU, 128-256Mi | Scheduling accuracy + noisy-neighbor protection |
| securityContext | non-root, read-only FS, drop ALL caps | Container escape mitigation |
| CSI Secrets Store | Key Vault secrets mounted at runtime | "Secrets never touch Git or the image" |

## Deployment flow

```
git push → Actions: test → lint → helm lint → docker build → Trivy →
push ACR (tag = git SHA) → helm upgrade --wait → rollout status → smoke test
```

Image tags are commit SHAs, never :latest in the cluster — rollback is
`helm rollback` or redeploying the previous SHA.

## Operations quick reference

```bash
kubectl logs -l app=hybrid-api-api -f --tail=100
kubectl describe pod <pod>                   # events: probe failures, OOM, pulls
kubectl top pods                             # against requests/limits
kubectl get hpa                              # current vs target utilization
helm history hybrid-api                      # what is deployed
helm rollback hybrid-api <rev>               # instant rollback
```
