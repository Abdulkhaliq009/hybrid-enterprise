resource "azurerm_log_analytics_workspace" "main" {
  name                = "law-hybrid-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  daily_quota_gb      = var.environment == "dev" ? 1 : -1
  tags                = var.tags
}

resource "azurerm_application_insights" "main" {
  name                = "appi-hybrid-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "Node.JS"
  tags                = var.tags
}

resource "azurerm_monitor_action_group" "main" {
  name                = "ag-hybrid-${var.environment}"
  resource_group_name = var.resource_group_name
  short_name          = "hybrid"
  tags                = var.tags

  email_receiver {
    name                    = "admin"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "failed_requests" {
  name                 = "alert-failed-requests-${var.environment}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  scopes               = [azurerm_application_insights.main.id]
  description          = "Failed requests exceed 10 in 15 minutes"
  severity             = 2
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  tags                 = var.tags

  criteria {
    query                   = "requests | where success == false | summarize count()"
    time_aggregation_method = "Count"
    threshold               = 10
    operator                = "GreaterThan"
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "vpn_disconnected" {
  name                 = "alert-vpn-health-${var.environment}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  scopes               = [azurerm_log_analytics_workspace.main.id]
  description          = "VPN tunnel state changes detected"
  severity             = 1
  evaluation_frequency = "PT5M"
  window_duration      = "PT15M"
  tags                 = var.tags

  criteria {
    query                   = "AzureDiagnostics | where Category == 'TunnelDiagnosticLog' | where OperationName == 'TunnelDisconnected'"
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"
  }

  action {
    action_groups = [azurerm_monitor_action_group.main.id]
  }
}
