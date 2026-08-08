$ErrorActionPreference = "Stop"
New-NetFirewallRule -DisplayName "SQL Server 1433" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
New-NetFirewallRule -DisplayName "IKE UDP 500" -Direction Inbound -Protocol UDP -LocalPort 500 -Action Allow
New-NetFirewallRule -DisplayName "NAT-T UDP 4500" -Direction Inbound -Protocol UDP -LocalPort 4500 -Action Allow
Write-Host "Firewall rules applied."
