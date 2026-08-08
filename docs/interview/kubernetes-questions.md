# Interview Q&A — Kubernetes

### What happens when an AKS pod crashes?

"The liveness probe fails, kubelet restarts the container — usually recovered
in seconds, and the PDB plus second replica mean users never noticed. If it
crash-loops, backoff kicks in and my pod-restart alert fires before users
complain. The readiness probe is the subtle part: it gates traffic, so a pod
that's up but not yet ready receives nothing. And I deliberately did not wire
the database check into readiness — if the DB drops, I want pods serving
clean 503s on data routes, not the entire deployment vanishing from the load
balancer."

### Requests vs limits — how did you choose the numbers?

"Requests (100m/128Mi) are what the scheduler reserves — set from observed
baseline under light load. Limits (500m/256Mi) are the ceiling — CPU throttles
at the limit, memory OOM-kills. The gap gives burst headroom. Wrong requests
are worse than wrong limits: too high wastes cluster capacity, too low
overcommits nodes. I'd revisit both from App Insights and kubectl top after
real traffic, not guess again."

### Why both HPA and cluster autoscaler?

"They scale different things. HPA adds pods when CPU crosses 70% — but pods
need somewhere to run. When pending pods can't schedule, the cluster
autoscaler adds nodes; when nodes sit empty, it removes them. HPA without CA
hits a capacity wall; CA without HPA has nothing to react to. Together:
2-10 pods across 1-4 nodes, and in dev the burst capacity is a spot pool at
up to 90% discount — evictable, which is fine for stateless replicas behind
a PDB."

### Why Helm rather than plain manifests?

"Templating and lifecycle. One chart serves dev and prod through values —
image tag, replica counts, the on-prem CIDR for the NetworkPolicy. And Helm
tracks releases: helm history shows what's deployed, helm rollback is my
instant recovery path. CI deploys by SHA tag, never :latest, so every rollout
is reproducible and reversible."
