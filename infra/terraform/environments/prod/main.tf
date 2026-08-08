terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  required_version = ">= 1.5.0"

  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "sttfstatehybrid"
    container_name       = "tfstate"
    key                  = "prod.tfstate"
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

module "platform" {
  source = "../../"

  environment          = "prod"
  resource_group_name  = "rg-hybrid-prod"
  location             = var.location
  onprem_public_ip     = var.onprem_public_ip
  onprem_address_space = var.onprem_address_space
  onprem_db_host       = var.onprem_db_host
  db_user              = var.db_user
  db_password          = var.db_password
  alert_email          = var.alert_email

  # Production sizing
  vpn_gateway_sku    = "VpnGw2"
  aks_node_count     = 3
  aks_min_nodes      = 3
  aks_max_nodes      = 10
  enable_spot_pool   = false
  enable_firewall    = true
  enable_asr         = true
  log_retention_days = 90
  monthly_budget_eur = 500
}
