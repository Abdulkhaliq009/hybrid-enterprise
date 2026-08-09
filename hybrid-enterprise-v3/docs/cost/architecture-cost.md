# Cost Breakdown — Full Architecture

Prices approximate, West Europe, EUR, 2026. Always verify with the Azure
Pricing Calculator before committing.

## Running cost per hour (prod profile)

| Resource | SKU | €/hr |
|---|---|---|
| VPN Gateway | VpnGw2 | 0.46 |
| AKS control plane | Free tier | 0.00 |
| AKS nodes | 3× B2s | 0.12 |
| Azure Firewall | Standard | 1.15 |
| Front Door | Premium base | 0.30 |
| Bastion | Basic | 0.18 |
| Log Analytics | ~2 GB/day | 0.20 |
| Backup + ASR vaults | Standard | 0.05 |
| Key Vault, ACR, misc | | 0.03 |
| **Total prod** | | **≈ 2.49/hr ≈ €1,800/mo** |

The Firewall and Front Door Premium dominate. This is why dev disables them.

## Dev profile

| Resource | Change | €/hr |
|---|---|---|
| VPN Gateway | VpnGw1 | 0.17 |
| AKS | 1× B2s + spot | 0.05 |
| Firewall | disabled | 0.00 |
| Front Door | Standard would save more; Premium kept for WAF parity | 0.30 |
| Everything else | quotas + LRS | 0.10 |
| **Total dev** | | **≈ 0.62/hr** |

With nightly shutdown (12h/day, weekdays only): **≈ €80/month**.
With terraform destroy between sessions: **≈ €2-5 per lab session**.
