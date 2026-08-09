#!/usr/bin/env bash
# VPN connection status is Connected
set -euo pipefail
RG="${RESOURCE_GROUP:-rg-hybrid-dev}"
STATUS=$(az network vpn-connection show --resource-group "$RG" \
  --name conn-onprem-dev --query connectionStatus -o tsv)
echo "Tunnel status: $STATUS"
[ "$STATUS" = "Connected" ]
