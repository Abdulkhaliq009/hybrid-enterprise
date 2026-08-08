# Disaster Recovery Strategy

## Recovery objectives

| Metric | Target | Justification |
|---|---|---|
| RPO (data loss tolerance) | 15 minutes | Product data changes slowly; 15-min app-consistent snapshots via ASR cover realistic write rates. Backup alone (daily) would mean up to 24h loss — unacceptable for order-like data. |
| RTO (downtime tolerance) | 1 hour | AKS redeploys from Helm in minutes; the long pole is DB failover + DNS. 1 hour is achievable without 24/7 staffing. |

These targets are deliberate: aggressive enough to be enterprise-credible,
loose enough to be achievable without active-active infrastructure.

## Failure scenarios and responses

| Scenario | Detection | Response | Expected recovery |
|---|---|---|---|
| AKS pod crash | Liveness probe | K8s restarts pod automatically | < 1 min, no action |
| AKS node failure | Node NotReady | Cluster autoscaler replaces node; PDB keeps 1 pod serving | < 10 min, no action |
| VPN tunnel drop | Monitor alert (TunnelDisconnected) | RRAS auto-reconnect; if not, re-run 02-configure-vpn.ps1 | < 15 min |
| On-prem SQL Server loss | /ready probe fails, alert fires | Restore latest backup to Azure VM from Recovery Services vault; repoint DB_HOST | < 60 min (the RTO driver) |
| Region outage (prod) | Azure status + all probes | ASR failover to North Europe; Front Door origin swap | < 60 min |

## The failover test (not just configuration)

Configuration without testing is hope, not DR. The drill:

```
1. Pre-check      tests/disaster-recovery/01-pre-check.sh   (baseline healthy)
2. Simulate loss  Stop SQL service on Windows Server
3. Detect         /ready returns 503; Monitor alert fires   (measure detection time)
4. Failover       Restore DB backup to standby / Azure VM
5. Repoint        Update DB_HOST secret in Key Vault; restart pods
6. Validate       tests/application/02-products-from-db.sh
7. Failback       Restore service on primary; repoint; validate again
8. Record         Actual RTO vs 60-min target in the drill log below
```

## Drill log

| Date | Scenario | Detection time | Actual RTO | Target met | Notes |
|---|---|---|---|---|---|
| _run your first drill and record it here_ | | | | | |
