#!/usr/bin/env bash
# All resources carry the required project tag
set -euo pipefail
RG="${RESOURCE_GROUP:-rg-hybrid-dev}"
UNTAGGED=$(az resource list --resource-group "$RG" --query "[?tags.project==null].name" -o tsv | wc -l)
echo "Untagged resources: $UNTAGGED"
[ "$UNTAGGED" -eq 0 ]
