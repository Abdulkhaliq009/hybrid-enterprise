#!/usr/bin/env bash
# AKS kubelet identity should have only AcrPull on the registry
set -euo pipefail
RG="${RESOURCE_GROUP:-rg-hybrid-dev}"
AKS=$(az aks list --resource-group "$RG" --query "[0].name" -o tsv)
KUBELET=$(az aks show --resource-group "$RG" --name "$AKS" --query identityProfile.kubeletidentity.objectId -o tsv)
ROLES=$(az role assignment list --assignee "$KUBELET" --query "[].roleDefinitionName" -o tsv)
echo "Kubelet roles: $ROLES"
echo "$ROLES" | grep -q "AcrPull"
