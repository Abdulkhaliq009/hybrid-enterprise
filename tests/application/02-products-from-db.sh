#!/usr/bin/env bash
# /products returns rows sourced from the on-prem database
set -euo pipefail
URL="${APP_URL:-http://localhost:8080}"
BODY=$(curl -s "$URL/products")
echo "$BODY" | grep -q '"source":"on-prem SQL Server"' && echo "Data is coming from on-prem SQL"
