# Interview Q&A — Terraform

### Why remote state, and what problem does locking solve?

"Local state fails in three ways: it's on one laptop (bus factor), it may
contain sensitive values in plaintext on that laptop, and two people applying
concurrently corrupt it. Remote state in Azure Storage fixes all three —
shared, access-controlled, and the blob lease provides locking so a second
apply blocks instead of racing. My CI applies through the same backend, so
pipeline and human can't collide either."

### How do dev and prod stay consistent?

"Same module, different inputs. environments/dev and environments/prod are
thin roots that call one shared composition with flags: dev runs VpnGw1, one
node plus a spot pool, firewall and ASR off, a 1 GB log cap. Prod runs VpnGw2,
3-10 nodes, firewall and ASR on. Because it's one module, topology drift
between environments is structurally impossible — a change lands in dev by
merge, and promoting it to prod is applying the same module version there."

### A resource was changed manually in the portal. What now?

"terraform plan shows it as drift. Two honest options: if the manual change
was wrong, apply reverts it; if it was right, I update the code to match and
plan converges to no-op. The wrong answer is ignoring it — unmanaged drift
means the code no longer describes reality, and the next apply becomes a
surprise. Azure Policy denying manual changes on tagged resources is the
preventive version."

### How do you handle secrets in Terraform?

"Variables marked sensitive, values injected from CI secrets or a local
tfvars that's gitignored — never committed. But the deeper answer: the state
file itself stores values in plaintext, so state access is secret access.
That's another argument for remote state with tight RBAC. For the runtime
path, Terraform writes the secret into Key Vault once, and everything
downstream reads from Key Vault — Terraform is the seeder, not the

distribution mechanism."

### Module count is 14 — when is a module worth it?

"A module earns its existence when it has a clean interface and a single
concern: vpn, aks, keyvault. I avoid modules that are just folders — if it
has one resource and no reuse, inline it. The test: can I describe the
module's contract in one sentence of inputs and outputs? If not, the
boundary is wrong."
