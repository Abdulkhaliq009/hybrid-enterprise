#!/usr/bin/env bash
# TCP 1433 reachable over the VPN (run from an AKS debug pod or VNet VM)
set -euo pipefail
DB_HOST="${DB_HOST:-192.168.1.10}"
timeout 5 bash -c "echo > /dev/tcp/${DB_HOST}/1433" \
  && echo "SQL port reachable at ${DB_HOST}:1433"
