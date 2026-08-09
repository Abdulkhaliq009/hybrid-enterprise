#!/usr/bin/env bash
# SQL Server port must NOT be reachable from the public internet
set -euo pipefail
PUBLIC_IP="${ONPREM_PUBLIC_IP:-}"
[ -n "$PUBLIC_IP" ] || { echo "Set ONPREM_PUBLIC_IP"; exit 1; }
if timeout 5 bash -c "echo > /dev/tcp/${PUBLIC_IP}/1433" 2>/dev/null; then
  echo "DANGER: SQL 1433 is publicly reachable"; exit 1
else
  echo "OK: SQL not publicly reachable"; exit 0
fi
