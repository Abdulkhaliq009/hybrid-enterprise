# Interview Q&A — Troubleshooting Narratives

Practice saying these out loud. Structure: symptom → hypothesis order →
commands → resolution → prevention.

### "Users report the app is down. Go."

"First 60 seconds: is it down for everyone or someone — curl the Front Door
URL myself. Then split the stack top-down: Front Door metrics for 5xx origin
errors; kubectl get pods for the workload; /health vs /products to separate
app-alive from data-path-broken. The architecture makes this fast: if /health
is 200 and /products is 500, I skip straight to the VPN and SQL. Tunnel
status via az network vpn-connection show; port test from a pod. Fix
whichever layer failed, then the prevention question: which alert should have
fired before the user called? If none did, that's the real bug."

### "Deploy went out, latency tripled."

"helm history — what changed. App Insights: is the added time in the app or
in dependencies? If dependency duration to SQL grew, check whether the new
code queries in a loop — the classic N+1. Meanwhile: helm rollback to the
previous SHA restores service while I read the diff. Rollback first, root-
cause second — users don't care about my debugging experience."

### "Security says the server is beaconing to an unknown IP."

"Contain: on-prem box, so pull the VPN interface and its internet route —
Bastion means I don't depend on the network being clean to reach it. Confirm:
firewall logs and Sentinel — which process, since when. The DSC baseline
gives me a known-good config to diff against. Eradicate depends on what I
find, but the honest lab answer is: single server, so restore from a backup
that predates the compromise, rotate every credential it held, and write the
Sentinel rule that would have caught it on day one instead of today."
