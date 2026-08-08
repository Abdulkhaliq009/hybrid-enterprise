# Network Topology

## Address plan

| Network | CIDR | Notes |
|---|---|---|
| Azure hub VNet | 10.10.0.0/16 | Room for spokes later |
| GatewaySubnet | 10.10.0.0/27 | Name is mandatory for VPN Gateway |
| snet-aks | 10.10.1.0/24 | 251 usable IPs; Azure CNI assigns pod IPs from here |
| AzureBastionSubnet | 10.10.2.0/27 | Name mandatory, /27 minimum |
| snet-private-endpoints | 10.10.3.0/24 | Key Vault PE lives here |
| AzureFirewallSubnet | 10.10.4.0/26 | Name mandatory, /26 minimum |
| On-prem LAN | 192.168.1.0/24 | Must not overlap Azure ranges |

## Security layers (defense in depth)

1. **Front Door WAF** — OWASP managed rules + bot protection at the edge
2. **NSG on snet-aks** — inbound only from AzureFrontDoor.Backend on 443
3. **Azure Firewall (prod)** — egress control: DNS, 443 to AzureCloud, 1433 to on-prem only
4. **K8s NetworkPolicy** — pods may egress only to on-prem:1433, DNS, 443
5. **Windows Firewall** — inbound 1433 + IKE ports only
6. **No public SQL** — verified by tests/security/02-no-public-sql.sh

## VPN specifics

- IKEv2, PSK auth, route-based Azure gateway
- Azure side advertises 10.10.0.0/16; on-prem RRAS routes it into the tunnel
- Traffic selector on-prem: 10.10.0.0/16:100 (the :100 is the route metric)
- NAT-T (UDP 4500) required because the lab sits behind a consumer router

## DNS

- privatelink.vaultcore.azure.net zone linked to the hub VNet
- Key Vault name resolves to 10.10.3.x inside the VNet, public IP outside
- On-prem DNS (Windows Server) can conditionally forward the privatelink zone
  to Azure DNS 168.63.129.16 via the tunnel for on-prem → Key Vault scenarios
