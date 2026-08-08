#!/usr/bin/env bash
# Resource group exists in Azure
set -euo pipefail
RG="${RESOURCE_GROUP:-rg-hybrid-dev}"
az group show --name "$RG" --query name -o tsv
