data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  tags = {
    project     = "hybrid-enterprise"
    environment = var.environment
    owner       = "abdulkhaliq"
    managed_by  = "terraform"
  }
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.tags
}

module "vpn" {
  source               = "./modules/vpn"
  resource_group_name  = azurerm_resource_group.main.name
  location             = var.location
  environment          = var.environment
  onprem_public_ip     = var.onprem_public_ip
  onprem_address_space = var.onprem_address_space
  vpn_gateway_sku      = var.vpn_gateway_sku
  tags                 = local.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  alert_email         = var.alert_email
  log_retention_days  = var.log_retention_days
  tags                = local.tags
}

module "acr" {
  source              = "./modules/acr"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  tags                = local.tags
}

module "aks" {
  source                     = "./modules/aks"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  environment                = var.environment
  aks_subnet_id              = module.vpn.aks_subnet_id
  acr_id                     = module.acr.acr_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  node_count                 = var.aks_node_count
  min_nodes                  = var.aks_min_nodes
  max_nodes                  = var.aks_max_nodes
  enable_spot_pool           = var.enable_spot_pool
  tags                       = local.tags
}

module "keyvault" {
  source                     = "./modules/keyvault"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  environment                = var.environment
  aks_secrets_identity       = module.aks.secrets_provider_identity
  private_endpoint_subnet_id = module.vpn.private_endpoint_subnet_id
  keyvault_dns_zone_id       = module.vpn.keyvault_dns_zone_id
  db_user                    = var.db_user
  db_password                = var.db_password
  tags                       = local.tags
}

module "firewall" {
  count                      = var.enable_firewall ? 1 : 0
  source                     = "./modules/firewall"
  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  environment                = var.environment
  firewall_subnet_id         = module.vpn.firewall_subnet_id
  onprem_address_space       = var.onprem_address_space
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.tags
}


module "bastion" {
  source              = "./modules/bastion"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  vnet_name           = module.vpn.vnet_name
  tags                = local.tags
}

module "security" {
  source                     = "./modules/security"
  resource_group_id          = azurerm_resource_group.main.id
  security_contact_email     = var.alert_email
  subscription_id            = data.azurerm_subscription.current.subscription_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
}


module "backup" {
  source              = "./modules/backup"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  tags                = local.tags
}

module "asr" {
  count               = var.enable_asr ? 1 : 0
  source              = "./modules/asr"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  environment         = var.environment
  tags                = local.tags
}

module "entraauth" {
  source   = "./modules/entraauth"
  app_name = "hybrid-api-${var.environment}"
}

module "costmanagement" {
  source              = "./modules/costmanagement"
  resource_group_name = azurerm_resource_group.main.name
  resource_group_id   = azurerm_resource_group.main.id
  location            = var.location
  environment         = var.environment
  alert_email         = var.alert_email
  monthly_budget_eur  = var.monthly_budget_eur
  tags                = local.tags
}


