# Onboard Windows Server 2025 to Azure Arc
param(
  [Parameter(Mandatory)][string]$SubscriptionId,
  [Parameter(Mandatory)][string]$ResourceGroup,
  [Parameter(Mandatory)][string]$TenantId,
  [string]$Location = "westeurope"
)
$ErrorActionPreference = "Stop"
Invoke-WebRequest -Uri "https://aka.ms/AzureConnectedMachineAgent" -OutFile "$env:TEMP\AzureConnectedMachineAgent.msi"
msiexec /i "$env:TEMP\AzureConnectedMachineAgent.msi" /qn | Out-Null
Start-Sleep -Seconds 10
& "C:\Program Files\AzureConnectedMachineAgent\azcmagent.exe" connect `
  --subscription-id $SubscriptionId --resource-group $ResourceGroup `
  --tenant-id $TenantId --location $Location --cloud AzureCloud
Write-Host "Azure Arc connected. Verify in portal: Azure Arc > Servers"
