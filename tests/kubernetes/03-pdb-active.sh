#!/usr/bin/env bash
# PodDisruptionBudget protects at least one pod
set -euo pipefail
kubectl get pdb hybrid-api-api-pdb -o jsonpath='minAvailable={.spec.minAvailable}'
echo ""
