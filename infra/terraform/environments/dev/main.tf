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
    key                  = "dev.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azuread" {}

module "platform" {
  source = "../../"

  environment          = "dev"
  resource_group_name  = "rg-hybrid-dev"
  location             = var.location
  onprem_public_ip     = var.onprem_public_ip
  onprem_address_space = var.onprem_address_space
  onprem_db_host       = var.onprem_db_host
  db_user              = var.db_user
  db_password          = var.db_password
  alert_email          = var.alert_email

  # Dev cost optimizations
  vpn_gateway_sku    = "VpnGw1AZ"
  aks_node_count     = 1
  aks_min_nodes      = 1
  aks_max_nodes      = 2
  enable_spot_pool   = true
  enable_firewall    = false
  enable_asr         = false
  log_retention_days = 30
  monthly_budget_eur = 50
}
