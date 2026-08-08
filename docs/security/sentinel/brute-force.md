# Detection: Brute-force authentication

**MITRE ATT&CK:** T1110 (Credential Access)
**Severity:** Medium | **Frequency:** hourly | **Source:** Windows SecurityEvent via Azure Arc

## Logic

Windows logs Event ID 4625 for every failed logon. More than 10 failures from
one source IP within an hour indicates password guessing.

## KQL

```kql
SecurityEvent
| where EventID == 4625
| summarize FailedAttempts = count(), Accounts = make_set(Account)
    by IpAddress, bin(TimeGenerated, 1h)
| where FailedAttempts > 10
| order by FailedAttempts desc
```

## Triage runbook

1. Check whether IpAddress is internal (192.168.1.0/24) or external.
2. Internal → likely a misconfigured service account; check the Accounts set.
3. External → confirm the firewall should even allow that path; block at
   Windows Firewall and review VPN/NAT rules.
4. Check for a following 4624 (successful logon) from the same IP — if present,
   escalate to incident: possible successful brute force.

## Tuning

- Raise threshold to 25 if service-account noise is high.
- Exclude known vulnerability-scanner IPs with `| where IpAddress !in (...)`.
