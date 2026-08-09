# Observability Stack

## Three layers, one destination

```
Application  → Application Insights (traces, deps, exceptions)  ┐
Kubernetes   → Container Insights (pods, nodes, kubelet)        ├→ Log Analytics → Sentinel
On-premises  → Azure Arc agent (SecurityEvent, System, Perf)    ┘
Optional     → Prometheus (in-cluster scrape) → Grafana dashboards
```

## What is monitored and why

| Signal | Source | Alert threshold |
|---|---|---|
| API failed requests | App Insights | >10 in 15 min |
| API latency p95 | App Insights | investigate >2s |
| Pod restarts | Container Insights | >3 in 1h |
| Node CPU/memory | Container Insights | >85% sustained |
| VPN tunnel state | Gateway diagnostics | any TunnelDisconnected |
| SQL connectivity | /ready probe | 503 = data path broken |
| Failed logons | Arc → SecurityEvent | Sentinel rule (see security docs) |
| Budget | Cost Management | 80% and 100% of monthly budget |

## Useful KQL

App latency percentiles:
```kql
requests
| summarize p50=percentile(duration,50), p95=percentile(duration,95), p99=percentile(duration,99)
    by bin(timestamp, 5m)
| render timechart
```

Dependency failures (is it the app or the database?):
```kql
dependencies
| where success == false
| summarize count() by target, resultCode, bin(timestamp, 15m)
```

Pod restarts:
```kql
KubePodInventory
| where ContainerRestartCount > 0
| summarize max(ContainerRestartCount) by Name, bin(TimeGenerated, 1h)
```

## Prometheus + Grafana (optional overlay)

Deploy kube-prometheus-stack via Helm for in-cluster metrics with Grafana
dashboards. Documented as an exercise; Container Insights covers the same
ground for the lab at lower operational cost.
