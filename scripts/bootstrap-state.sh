#!/usr/bin/env bash
# One-time: create the Terraform remote state backend
set -euo pipefail
LOCATION="${1:-westeurope}"
az group create --name rg-terraform-state --location "$LOCATION"
az storage account create --name sttfstatehybrid \
  --resource-group rg-terraform-state --location "$LOCATION" \
  --sku Standard_LRS --min-tls-version TLS1_2 --allow-blob-public-access false
az storage container create --name tfstate --account-name sttfstatehybrid
az storage account blob-service-properties update \
  --account-name sttfstatehybrid --enable-versioning true
echo "State backend ready: rg-terraform-state / sttfstatehybrid / tfstate"
