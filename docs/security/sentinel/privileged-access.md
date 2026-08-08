# Detection: Privileged group changes

**MITRE ATT&CK:** T1078 (Privilege Escalation)
**Severity:** High | **Frequency:** hourly | **Source:** SecurityEvent 4728/4732/4756

## Logic

Additions to Domain Admins / Enterprise Admins / Administrators are rare,
change-controlled events. Any unplanned addition is a potential compromise.

## KQL

```kql
SecurityEvent
| where EventID in (4728, 4732, 4756)
| where TargetUserName has_any ("Domain Admins", "Enterprise Admins", "Administrators")
| project TimeGenerated, Computer, SubjectAccount, TargetUserName, MemberName
```

## Triage runbook

1. Match against change tickets. No ticket → treat as incident.
2. Identify SubjectAccount (who made the change). If that account itself was
   recently added → assume chained escalation.
3. Remove the membership, reset both accounts, review 4624/4672 logons for
   the affected accounts over the previous 24h.
