# DevSecOps Pipeline

## Application pipeline (every PR and push)

```
Pull Request
    ↓
Unit tests (jest)          — logic is correct
    ↓
ESLint                     — code quality
    ↓
Helm lint                  — chart is valid
    ↓
Docker build               — image builds reproducibly
    ↓
Trivy scan                 — no CRITICAL/HIGH CVEs in the image
    ↓                        (merge gate)
─── on merge to main ───
    ↓
Push to ACR (tag = SHA)
    ↓
helm upgrade --wait
    ↓
rollout status + smoke test
```

## Infrastructure pipeline

```
PR touching infra/terraform/**
    ↓
terraform fmt -check       — consistent style
    ↓
terraform validate         — syntactically sound
    ↓
tfsec + Checkov            — security misconfigurations
    ↓                        (soft-fail in lab; hard gate in prod)
─── on merge ───
    ↓
terraform plan → apply (dev environment, OIDC auth)
```

## Why each gate exists

| Gate | Catches | Real example it would catch |
|---|---|---|
| jest | Broken logic | /products returning wrong shape |
| ESLint | Bug-prone patterns | unused error variable hiding a failure |
| helm lint | Bad templates | mis-indented values breaking deploy |
| Trivy | Vulnerable base images | CVE in an old node:alpine layer |
| tfsec | Insecure IaC | Key Vault with public network access |
| Checkov | Policy violations | storage account without HTTPS-only |
| gitleaks (weekly) | Committed secrets | a tfvars with a real password |

## Credential model

GitHub Actions authenticates to Azure via **OIDC federation** — no stored
client secrets. The federated credential trusts only this repo + environment,
so a leaked workflow file alone grants nothing.
