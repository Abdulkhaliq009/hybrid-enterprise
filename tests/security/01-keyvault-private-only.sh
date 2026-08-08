#!/usr/bin/env bash
# Key Vault denies public network access
set -euo pipefail
RG="${RESOURCE_GROUP:-rg-hybrid-dev}"
KV=$(az keyvault list --resource-group "$RG" --query "[0].name" -o tsv)
ACTION=$(az keyvault show --name "$KV" --query "properties.networkAcls.defaultAction" -o tsv)
echo "Key Vault $KV default action: $ACTION"
[ "$ACTION" = "Deny" ]
