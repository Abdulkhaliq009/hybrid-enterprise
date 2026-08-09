resource "azurerm_public_ip" "firewall" {
  name                = "pip-fw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_firewall" "main" {
  name                = "fw-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.firewall.id
  }
}

resource "azurerm_firewall_network_rule_collection" "allow_core" {
  name                = "allow-core-outbound"
  azure_firewall_name = azurerm_firewall.main.name
  resource_group_name = var.resource_group_name
  priority            = 100
  action              = "Allow"

  rule {
    name                  = "dns"
    source_addresses      = ["10.10.0.0/16"]
    destination_ports     = ["53"]
    destination_addresses = ["*"]
    protocols             = ["TCP", "UDP"]
  }

  rule {
    name                  = "https-to-azure"
    source_addresses      = ["10.10.1.0/24"]
    destination_ports     = ["443"]
    destination_addresses = ["AzureCloud"]
    protocols             = ["TCP"]
  }

  rule {
    name                  = "sql-to-onprem"
    source_addresses      = ["10.10.1.0/24"]
    destination_ports     = ["1433"]
    destination_addresses = [var.onprem_address_space]
    protocols             = ["TCP"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "firewall" {
  name                       = "diag-firewall"
  target_resource_id         = azurerm_firewall.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
