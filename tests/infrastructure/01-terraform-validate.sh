#!/usr/bin/env bash
# Terraform configuration is syntactically valid
set -euo pipefail
cd "$(dirname "$0")/../../infra/terraform/environments/dev"
terraform init -backend=false -input=false >/dev/null
terraform validate
