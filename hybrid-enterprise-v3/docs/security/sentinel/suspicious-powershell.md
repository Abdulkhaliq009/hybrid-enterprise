# Detection: Suspicious PowerShell

**MITRE ATT&CK:** T1059.001 (Execution)
**Severity:** High | **Frequency:** hourly | **Source:** SecurityEvent 4688 (process creation)

## Logic

Attackers use encoded commands and download cradles to run payloads without
touching disk. Requires command-line auditing enabled (done by 06-dsc-config.ps1).

## KQL

```kql
SecurityEvent
| where EventID == 4688
| where Process has "powershell.exe"
| where CommandLine has_any ("-enc", "-encodedcommand", "downloadstring",
    "iex", "invoke-expression", "bypass", "hidden")
| project TimeGenerated, Computer, Account, CommandLine
```

## Triage runbook

1. Decode any `-enc` payload: `[Text.Encoding]::Unicode.GetString([Convert]::FromBase64String("..."))`
2. Legitimate admin tooling (SCCM, some installers) also triggers this —
   check the parent process and the Account.
3. If the account is a standard user or the command downloads from an unknown
   host: isolate the machine (disconnect VPN interface), preserve logs, rotate
   the account credentials.
