#!/usr/bin/env bash
# Pre-failover: primary workload healthy, note baseline
set -euo pipefail
URL="${APP_URL:-http://localhost:8080}"
curl -sf "$URL/health" >/dev/null && echo "Primary healthy at $(date -u +%H:%M:%SZ)"
