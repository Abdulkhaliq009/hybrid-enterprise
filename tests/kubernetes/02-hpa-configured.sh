#!/usr/bin/env bash
# HPA exists with expected bounds
set -euo pipefail
kubectl get hpa hybrid-api-api-hpa -o jsonpath='min={.spec.minReplicas} max={.spec.maxReplicas}'
echo ""
MIN=$(kubectl get hpa hybrid-api-api-hpa -o jsonpath='{.spec.minReplicas}')
[ "$MIN" -ge 2 ]
