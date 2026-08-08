resource "azurerm_recovery_services_vault" "main" {
  name                = "rsv-hybrid-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = var.environment == "prod" ? true : false
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "main" {
  name                = "policy-vm-${var.environment}"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.main.name

  backup {
    frequency = "Daily"
    time      = "02:00"
  }

  retention_daily {
    count = var.environment == "prod" ? 30 : 7
  }

  retention_weekly {
    count    = 4
    weekdays = ["Sunday"]
  }
}
