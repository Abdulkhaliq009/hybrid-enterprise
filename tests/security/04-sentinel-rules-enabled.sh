#!/usr/bin/env bash
# Sentinel analytics rules exist and are enabled
set -euo pipefail
RG="${RESOURCE_GROUP:-rg-hybrid-dev}"
WS=$(az monitor log-analytics workspace list --resource-group "$RG" --query "[0].name" -o tsv)
COUNT=$(az sentinel alert-rule list --resource-group "$RG" --workspace-name "$WS" --query "length([?enabled])" -o tsv 2>/dev/null || echo 0)
echo "Enabled Sentinel rules: $COUNT"
[ "$COUNT" -ge 3 ]
