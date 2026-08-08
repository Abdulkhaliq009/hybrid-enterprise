#!/usr/bin/env bash
# NetworkPolicy is applied to the app pods
set -euo pipefail
kubectl get networkpolicy hybrid-api-api-netpol -o name
