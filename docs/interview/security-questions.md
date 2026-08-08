# Interview Q&A — Security

### Why Managed Identity instead of storing credentials?

"Stored credentials have three problems: they leak (Git history, logs,
screenshots), they don't rotate themselves, and revoking them breaks things
unpredictably. A managed identity is bound to the Azure resource — the AKS
secrets provider in my case. There is no password to steal: Azure issues
short-lived tokens to the platform itself. In this project the pods mount Key
Vault secrets via the CSI driver using that identity, GitHub Actions uses OIDC
federation, and the only long-lived secret in the whole system is the SQL
login — which lives in Key Vault, not in code."

### How do you prevent secrets ending up in Git?

"Layers. First, structurally: the app reads configuration from environment
variables that come from Key Vault-backed mounts, so there's no place in the
code where a secret would go. Second, .gitignore excludes tfvars and .env.
Third, gitleaks runs weekly in CI to catch mistakes. Fourth, the CI pipeline
itself holds no secrets — OIDC federation means even the workflow files
contain nothing exploitable."

### An attacker compromises one AKS pod. What can they do?

"Less than they'd hope. The container runs as non-root with a read-only
filesystem and all capabilities dropped, so persistence inside the container
is hard. The NetworkPolicy limits egress to exactly three destinations: DNS,
443, and the on-prem SQL server on 1433 — they can't scan the VNet or reach
the cloud metadata endpoint usefully. The pod identity can read two Key Vault
secrets and nothing else. The blast radius is: the DB credentials. That's why
detection matters — the Sentinel rules on failed logons and unusual activity
are the next layer, because prevention alone always eventually fails."

### How would you investigate a Sentinel brute-force incident?

"First, scope: the rule gives me the source IP, the target accounts, and the
count. Is the IP internal or external? Internal usually means a misconfigured
service; external means the firewall path needs review. Second, impact: I
query for Event 4624 — a successful logon from the same IP after the failures.
No success: block the IP, ticket, done. Success: now it's a compromise —
isolate the machine by dropping the VPN interface, reset the account, and
walk forward through what that session touched. The full runbook is in the
repo under docs/security/sentinel."

### What's the difference between the WAF and the Azure Firewall here?

"Direction and layer. The WAF at Front Door inspects inbound HTTP —
SQL injection, XSS, bot patterns — before traffic reaches my network. The
Azure Firewall governs outbound traffic from the AKS subnet: my pods may only
reach DNS, Azure services on 443, and on-prem SQL on 1433. If a pod is
compromised, the WAF did its job and lost; the firewall is what stops the
malware from calling home."
