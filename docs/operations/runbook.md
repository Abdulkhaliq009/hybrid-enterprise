# Day-2 Operations Runbook

## Daily (automated, verify weekly)

- Backups ran (Recovery Services vault → Backup Jobs)
- No firing alerts (Azure Monitor → Alerts)
- Budget burn rate on track (Cost Management)

## Weekly

- Review Sentinel incidents — triage per docs/security/sentinel/ runbooks
- Check Defender for Cloud secure score; fix new recommendations
- `kubectl get pods -A | grep -v Running` — anything stuck?
- Dependabot PRs — merge patch bumps after CI passes

## Monthly

- AKS upgrade check: `az aks get-upgrades`
- Restore-test one SQL backup (docs/disaster-recovery/backup-restore.md)
- Rotate the VPN PSK (update Key Vault + LNG + RRAS)
- Review Log Analytics ingestion vs the daily cap

## Quarterly

- Full DR drill (docs/disaster-recovery/strategy.md) — record actual RTO
- Access review: RBAC assignments, Key Vault roles, break-glass account
- Terraform provider/version bumps in a dedicated PR

## Standard change procedure

1. Branch → change → PR
2. CI gates green (tests, tfsec, Trivy)
3. Review the terraform plan output in the PR
4. Merge → auto-apply to dev → verify → promote to prod deliberately
