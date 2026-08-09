#!/usr/bin/env bash
# Build, push, and deploy the app manually (without CI)
set -euo pipefail
ACR="${1:?Usage: ./local-deploy.sh <acr-name> [tag]}"
TAG="${2:-manual-$(date +%Y%m%d%H%M)}"
az acr login --name "$ACR"
docker build -t "$ACR.azurecr.io/hybrid-api:$TAG" ./app
docker push "$ACR.azurecr.io/hybrid-api:$TAG"
helm upgrade --install hybrid-api ./helm/hybrid-api \
  --set image.repository="$ACR.azurecr.io/hybrid-api" \
  --set image.tag="$TAG" --wait
kubectl rollout status deployment/hybrid-api-api
