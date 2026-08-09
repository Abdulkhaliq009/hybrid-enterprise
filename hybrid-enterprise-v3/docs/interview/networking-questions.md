# Interview Q&A — Networking

### Explain the S2S VPN like I'm a junior admin.

"Two routers agree on a shared secret and build an encrypted tunnel across
the internet. Azure's side is the VPN Gateway with a public IP; my side is
Windows Server running RRAS behind my home router. IKEv2 negotiates the
crypto, then IPSec encrypts every packet. Azure knows 192.168.1.0/24 lives
on the other end (Local Network Gateway); my server knows 10.10.0.0/16 goes
into the tunnel. To an app, it's just routing — a pod talks to 192.168.1.10
and has no idea an encrypted internet crossing happened."

### Why must the address spaces not overlap?

"Routing is destination-based. If both sides used 192.168.1.0/24, a packet
for 192.168.1.10 matches the local network on both ends and never enters the
tunnel. My plan: Azure 10.10.0.0/16, on-prem 192.168.1.0/24 — unambiguous.
Overlap is the classic day-one hybrid design mistake and it's miserable to
fix later because someone has to re-IP."

### How does DNS work across the two environments?

"Three zones of truth. Public DNS resolves Front Door. Inside the VNet, the
privatelink zone makes the Key Vault name resolve to its private endpoint
10.10.3.x. On-premises, Windows Server DNS owns the AD domain, and can
conditionally forward the privatelink zone through the tunnel to Azure DNS
(168.63.129.16) if on-prem processes ever need the vault. The failure mode
to know: if the privatelink zone isn't linked to the VNet, clients resolve
the public IP and the Deny ACL blocks them — 'works from portal, fails from
pod' is almost always this."

### Where exactly can traffic enter and leave?

"In: only 443 via Front Door — the NSG source-restricts to the Front Door
backend service tag, so origin bypass fails. In over VPN: IKE UDP 500/4500 to
the on-prem side. Out from AKS: DNS, 443 to AzureCloud, 1433 to on-prem —
enforced twice, by Azure Firewall at the subnet edge in prod and by the
K8s NetworkPolicy at the pod. SQL 1433 is reachable only through the tunnel;
there's a test in the repo that fails the suite if it ever becomes publicly
reachable."
