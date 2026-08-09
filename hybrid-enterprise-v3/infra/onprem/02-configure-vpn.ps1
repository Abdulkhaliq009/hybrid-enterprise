# Usage: .\02-configure-vpn.ps1 -AzureVpnGatewayIp "x.x.x.x" -SharedSecret (Read-Host -AsSecureString "PSK")
param(
  [Parameter(Mandatory)][string]$AzureVpnGatewayIp,
  [Parameter(Mandatory)][SecureString]$SharedSecret
)
$ErrorActionPreference = "Stop"
$psk = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
  [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SharedSecret)
)
Install-WindowsFeature RemoteAccess, Routing -IncludeManagementTools | Out-Null
Set-Service -Name RemoteAccess -StartupType Automatic
Start-Service RemoteAccess
Start-Service IKEext
Start-Service RasMan
Add-VpnS2SInterface -Name "AzureS2S" -Destination $AzureVpnGatewayIp `
  -Protocol IKEv2 -AuthenticationMethod PSKOnly `
  -SharedSecret $psk -IPv4Subnet "10.10.0.0/16:100" -Persistent
Connect-VpnS2SInterface -Name "AzureS2S"
Write-Host "Verify: Get-VpnS2SInterface -Name AzureS2S"
