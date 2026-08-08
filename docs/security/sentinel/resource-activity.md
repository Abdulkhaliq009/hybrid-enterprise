# Detection: Unexpected Azure resource creation

**MITRE ATT&CK:** T1578 (Impact / resource hijacking)
**Severity:** Low | **Frequency:** hourly | **Source:** AzureActivity

## Logic

Resource writes outside 06:00-22:00 are unusual for a single-owner lab and a
common sign of compromised credentials being used for cryptomining.

## KQL

```kql
AzureActivity
| where OperationNameValue endswith "write"
| where ActivityStatusValue == "Success"
| extend hour = hourofday(TimeGenerated)
| where hour < 6 or hour > 22
| project TimeGenerated, Caller, OperationNameValue, ResourceGroup, ResourceProviderValue
```

## Triage runbook

1. Was it CI/CD? The GitHub OIDC identity is a known Caller — exclude it.
2. Unknown caller creating VMs/GPU SKUs → revoke sessions, rotate credentials,
   delete resources, check Cost Management for spend spike.

## SOAR follow-up (documented pattern)

Incident → Automation rule → Logic App → Teams/email notification with the
Caller and resource list. The Logic App playbook is a documented next step,
not deployed by default in dev (cost).
