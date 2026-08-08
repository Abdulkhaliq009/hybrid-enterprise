#!/usr/bin/env bash
# Backup vault holds recent recovery points (RPO check)
set -euo pipefail
RG="${RESOURCE_GROUP:-rg-hybrid-dev}"
VAULT=$(az backup vault list --resource-group "$RG" --query "[0].name" -o tsv)
echo "Vault: $VAULT"
az backup item list --resource-group "$RG" --vault-name "$VAULT" \
  --backup-management-type AzureIaasVM --query "[].properties.lastBackupTime" -o tsv
