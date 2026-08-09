# Troubleshooting Scenarios

Each scenario: symptom → diagnosis path → resolution. These double as
interview practice — the debugging narrative matters more than the fix.

## 1. /products returns 500, /health returns 200

App is alive; data path is broken.
```bash
kubectl logs -l app=hybrid-api-api --tail=50        # look for SQL error text
kubectl exec -it <pod> -- sh -c 'nc -zv 192.168.1.10 1433 || echo BLOCKED'
```
- Timeout → VPN or routing: `az network vpn-connection show ... --query connectionStatus`
- Connection refused → SQL service or Windows Firewall on the server
- Login failed → Key Vault secret vs actual SQL login mismatch

## 2. VPN shows "Connecting" forever

- Wrong PSK: must match in LNG resource and RRAS interface — re-run
  02-configure-vpn.ps1 with the exact key
- NAT problem: home router must forward UDP 500 + 4500 to the server
- Wrong public IP in the Local Network Gateway (home IP changed) —
  `curl ifconfig.me`, update lng via terraform apply

## 3. Pod ImagePullBackOff

```bash
kubectl describe pod <pod> | grep -A5 Events
```
- 401 → AcrPull role missing on kubelet identity (tests/security/03 catches this)
- manifest unknown → the tag doesn't exist; check the Actions build log

## 4. Pod OOMKilled

```bash
kubectl describe pod <pod> | grep -B2 OOMKilled
kubectl top pods
```
Memory limit (256Mi) exceeded. Check for a leak first (App Insights memory
trend); only raise the limit with a reason, not as a reflex.

## 5. Key Vault access denied from pod

- CSI provider identity lacks "Key Vault Secrets User" role → check
  module.keyvault role assignment
- Private endpoint DNS: from a pod, `nslookup <kv>.vault.azure.net` must
  return 10.10.3.x — if it returns a public IP, the DNS zone link is broken

## 6. Sentinel rule never fires

- Arc agent connected? `azcmagent show` on the server
- SecurityEvent table receiving data? `SecurityEvent | take 5` in Log Analytics
- Command-line auditing on? (needed for 4688 CommandLine) — DSC config sets it

## 7. Front Door returns 502

- Origin health probes failing → is /health reachable from
  AzureFrontDoor.Backend through the NSG?
- Certificate mismatch on origin → origin_host_header must match the backend cert
