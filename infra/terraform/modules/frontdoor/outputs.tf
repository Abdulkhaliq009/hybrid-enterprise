output "endpoint_url" { value = "https://${azurerm_cdn_frontdoor_endpoint.main.host_name}" }
output "profile_id" { value = azurerm_cdn_frontdoor_profile.main.id }
output "origin_group_id" { value = azurerm_cdn_frontdoor_origin_group.main.id }
