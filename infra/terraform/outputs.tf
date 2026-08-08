output "vpn_gateway_public_ip" {
  value       = module.vpn.gateway_public_ip
  description = "For on-prem VPN config"
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "aks_cluster_name" {
  value = module.aks.cluster_name
}

output "key_vault_name" {
  value = module.keyvault.key_vault_name
}

output "log_analytics_workspace_id" {
  value = module.monitoring.log_analytics_workspace_id
}

output "app_insights_connection_string" {
  value     = module.monitoring.app_insights_connection_string
  sensitive = true
}
