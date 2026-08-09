#!/usr/bin/env bash
# /health returns 200 through the Front Door URL (or port-forward)
set -euo pipefail
URL="${APP_URL:-http://localhost:8080}"
CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL/health")
echo "GET /health -> $CODE"
[ "$CODE" = "200" ]
