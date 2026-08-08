# Interview Q&A — Architecture

### Why AKS instead of App Service?

"For the workload alone, App Service would honestly be simpler and cheaper.
I chose AKS deliberately for three reasons: first, it let me implement
production patterns that App Service abstracts away — network policies,
pod disruption budgets, per-pod security contexts. Second, autoscaling at
two levels: HPA for pods, cluster autoscaler for nodes. Third, portability —
the same Helm chart deploys anywhere. The trade-off is operational overhead:
upgrades, node management, more moving parts. I'd recommend App Service to a
team without Kubernetes experience — the best architecture is one the team
can actually operate."

### Why is the database on-premises?

"It simulates a data residency requirement, which is common in German
enterprises — regulated data stays on-premises while the application layer
modernizes in the cloud. It also forced me to build real hybrid networking:
Site-to-Site VPN, split routing, DNS across environments. If there were no
residency requirement, I'd use Azure SQL and remove the entire VPN dependency
— the hybrid design is a response to a constraint, not a preference."

### Walk me through a request.

"A user hits the Front Door URL. TLS terminates at the nearest edge, the WAF
evaluates OWASP managed rules, and the request routes to the AKS origin. The
NSG only accepts traffic from the Front Door backend range, so you can't
bypass the WAF by hitting the origin directly. The ingress routes to a pod.
The pod already has the DB credentials mounted from Key Vault through the CSI
driver — fetched over a private endpoint, never over public internet. The pod
opens a connection to 192.168.1.10:1433, which routes into the IPSec tunnel
through the VPN Gateway, exits at the RRAS server on-premises, and hits SQL
Server. The response returns the same path. Telemetry from every hop lands in
Log Analytics."

### What is the single point of failure?

"The on-premises side. One Windows Server, one SQL instance, one internet
connection, one VPN endpoint. Azure-side everything is redundant — multiple
pods, multiple nodes possible, Front Door is globally distributed. That
asymmetry is honest for a lab and it's exactly what the DR strategy addresses:
documented RPO/RTO, daily backups replicated to Azure, and a tested restore
path to an Azure VM if the on-prem side dies. In production I'd add a second
SQL node with an Always On availability group and dual internet uplinks."

### Why hub network design with no spokes?

"The address plan is a /16 hub with subnets for gateway, AKS, Bastion, private
endpoints, and firewall. There are no spokes yet because there's one workload
— but the design leaves room: a second workload would get its own spoke VNet
peered to the hub, inheriting the VPN and firewall. Building the hub-spoke
skeleton before you need it costs nothing; retrofitting it later costs a
re-IP."
