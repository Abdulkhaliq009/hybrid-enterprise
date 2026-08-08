# Interview Q&A — Azure

### What happens if the VPN fails?

"The app degrades predictably: /health stays green because the pods are fine,
/ready goes 503 because the database is unreachable, and the readiness design
means Front Door keeps routing — users get clean errors on data endpoints
rather than timeouts. Detection is under five minutes via the
TunnelDisconnected alert. Recovery: RRAS auto-reconnects transient drops; a
real failure means checking in order — did the home public IP change (update
the Local Network Gateway), are UDP 500/4500 still forwarded, does the PSK
still match. The troubleshooting doc has the exact sequence. For production
I'd run active-active gateways and a second ISP — the tunnel is the
availability bottleneck of the whole design and I say so openly."

### Front Door vs Application Gateway vs Load Balancer — when which?

"Load Balancer is layer 4 — TCP, regional, no HTTP awareness. Application
Gateway is layer 7 regional — path routing, WAF, inside your VNet. Front Door
is layer 7 global — anycast edge network, CDN caching, global failover, WAF.
I used Front Door because the design brief was global entry with CDN and WAF
in one control plane. If everything lived in one region with no caching need,
Application Gateway would be the right-sized answer."

### What does Azure Arc actually give you here?

"It makes my on-prem Windows Server a first-class Azure resource. Concretely:
its SecurityEvent logs flow into Log Analytics, which is what feeds the
Sentinel detections — without Arc, my SIEM is blind to the most important
machine in the architecture. It also enables Azure Policy and extensions on
the box. It's the answer to 'how do you manage the on-prem half with cloud
tooling' — one control plane for both worlds."

### Private endpoint vs service endpoint?

"A service endpoint keeps traffic on the Azure backbone but the service still
has a public IP — you're allowlisting your subnet on a public front door. A
private endpoint injects a NIC with a private IP from my VNet into the
service; combined with the privatelink DNS zone, kv.vault.azure.net resolves
to 10.10.3.x and the public path can be denied entirely. I used a private
endpoint for Key Vault because 'default_action = Deny' plus a private IP is a
categorically stronger posture than a filtered public endpoint."
