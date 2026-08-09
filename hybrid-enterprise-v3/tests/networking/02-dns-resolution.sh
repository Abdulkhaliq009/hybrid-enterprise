#!/usr/bin/env bash
# Key Vault private DNS resolves to a private IP (from inside the VNet)
set -euo pipefail
KV="${KEY_VAULT_NAME:-}"
[ -n "$KV" ] || { echo "Set KEY_VAULT_NAME"; exit 1; }
IP=$(dig +short "${KV}.vault.azure.net" | tail -1)
echo "Resolved: $IP"
case "$IP" in 10.10.*) exit 0 ;; *) echo "Not a private IP — run from inside VNet"; exit 1 ;; esac
