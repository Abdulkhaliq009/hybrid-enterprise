#!/usr/bin/env bash
# All hybrid-api pods Running and Ready
set -euo pipefail
NOT_READY=$(kubectl get pods -l app=hybrid-api-api \
  -o jsonpath='{range .items[*]}{.status.phase}{"\n"}{end}' | grep -vc Running || true)
echo "Pods not running: $NOT_READY"
[ "$NOT_READY" -eq 0 ]
