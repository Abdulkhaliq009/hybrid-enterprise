# Azure Automation runbook: scale AKS to zero nights/weekends
# Schedule: 18:00 scale down, 08:00 scale up (via Automation schedules)
param(
  [Parameter(Mandatory)][string]$ResourceGroup,
  [Parameter(Mandatory)][string]$AksName,
  [ValidateSet("down","up")][string]$Direction = "down"
)
$nodeCount = if ($Direction -eq "down") { 0 } else { 1 }
Write-Output "Scaling $AksName system pool to $nodeCount nodes..."
az aks nodepool scale --resource-group $ResourceGroup --cluster-name $AksName `
  --name system --node-count $nodeCount
Write-Output "Done."
