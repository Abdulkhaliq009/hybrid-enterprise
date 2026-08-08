output "vnet_id" { value = azurerm_virtual_network.hub.id }
output "vnet_name" { value = azurerm_virtual_network.hub.name }
output "aks_subnet_id" { value = azurerm_subnet.aks.id }
output "firewall_subnet_id" { value = azurerm_subnet.firewall.id }
output "private_endpoint_subnet_id" { value = azurerm_subnet.private_endpoints.id }
output "gateway_public_ip" { value = azurerm_public_ip.vpn_gateway.ip_address }
output "keyvault_dns_zone_id" { value = azurerm_private_dns_zone.keyvault.id }
