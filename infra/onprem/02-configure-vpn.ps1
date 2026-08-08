# Usage: .\02-configure-vpn.ps1 -AzureVpnGatewayIp "x.x.x.x"
param([Parameter(Mandatory)][string]$AzureVpnGatewayIp)
$ErrorActionPreference = "Stop"
Install-WindowsFeature RemoteAccess, RRAS, RRAS-Role -IncludeManagementTools
& netsh routing ip install
Add-VpnS2SInterface -Name "AzureS2S" -Destination $AzureVpnGatewayIp `
  -Protocol IKEv2 -AuthenticationMethod PSKOnly `
  -SharedSecret "HybridLabSharedKey123!" -IPv4Subnet "10.10.0.0/16:100"
Connect-VpnS2SInterface -Name "AzureS2S"
Write-Host "Verify: Get-VpnS2SInterface -Name AzureS2S"
