resource "azurerm_recovery_services_vault" "asr" {
  name                = "rsv-asr-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = false
  tags                = var.tags
}

resource "azurerm_site_recovery_fabric" "primary" {
  name                = "fabric-primary"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.asr.name
  location            = var.location
}

resource "azurerm_site_recovery_fabric" "secondary" {
  name                = "fabric-secondary"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.asr.name
  location            = var.dr_location
}

resource "azurerm_site_recovery_protection_container" "primary" {
  name                 = "container-primary"
  resource_group_name  = var.resource_group_name
  recovery_vault_name  = azurerm_recovery_services_vault.asr.name
  recovery_fabric_name = azurerm_site_recovery_fabric.primary.name
}

resource "azurerm_site_recovery_protection_container" "secondary" {
  name                 = "container-secondary"
  resource_group_name  = var.resource_group_name
  recovery_vault_name  = azurerm_recovery_services_vault.asr.name
  recovery_fabric_name = azurerm_site_recovery_fabric.secondary.name
}

resource "azurerm_site_recovery_replication_policy" "main" {
  name                                                 = "policy-rpo15"
  resource_group_name                                  = var.resource_group_name
  recovery_vault_name                                  = azurerm_recovery_services_vault.asr.name
  recovery_point_retention_in_minutes                  = 1440
  application_consistent_snapshot_frequency_in_minutes = 60
}
