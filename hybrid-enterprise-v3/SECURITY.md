# Security Policy

## Reporting a vulnerability

This is a lab/portfolio project. If you find a security issue in the code or
configurations, open a GitHub issue or contact the maintainer via LinkedIn.

## Security design principles applied

1. **No secrets in Git** — all credentials live in Azure Key Vault; the app
   authenticates via Managed Identity. GitHub Actions uses OIDC federation,
   not stored credentials.
2. **Least privilege** — RBAC role assignments are scoped to the minimum
   resource level. The AKS kubelet identity has only AcrPull.
3. **Private by default** — Key Vault and internal services use private
   endpoints. SQL Server is never exposed publicly; access is only over the
   encrypted VPN tunnel.
4. **Defense in depth** — WAF at the edge, NSGs on subnets, Azure Firewall
   for egress, network policies inside AKS, host firewall on Windows Server.
5. **Detection** — Microsoft Sentinel ingests logs from Entra ID, Azure
   Activity, AKS, and Windows Server, with scheduled analytics rules.

## Known lab simplifications

- VPN pre-shared key is stored in tfvars (in production: Key Vault + rotation)
- SQL auth uses SQL logins (in production: Entra-integrated auth)
- Sentinel rules are examples, not a complete detection catalogue
