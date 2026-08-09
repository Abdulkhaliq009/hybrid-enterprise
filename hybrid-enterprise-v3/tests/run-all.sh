#!/usr/bin/env bash
# Run the full test suite. Requires: az, kubectl, sqlcmd (optional), terraform
set -uo pipefail

PASS=0; FAIL=0
run() {
  echo "── $1"
  if bash "$1"; then PASS=$((PASS+1)); echo "   ✓ PASS"; else FAIL=$((FAIL+1)); echo "   ✗ FAIL"; fi
}

for t in tests/infrastructure/*.sh tests/networking/*.sh tests/security/*.sh tests/kubernetes/*.sh tests/application/*.sh; do
  [ -f "$t" ] && run "$t"
done

echo ""
echo "Results: $PASS passed, $FAIL failed"
exit $FAIL
