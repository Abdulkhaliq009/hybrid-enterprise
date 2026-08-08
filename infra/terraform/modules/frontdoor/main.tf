resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "afd-hybrid-${var.environment}"
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "afd-ep-hybrid-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  name                = "wafhybrid${var.environment}"
  resource_group_name = var.resource_group_name
  sku_name            = azurerm_cdn_frontdoor_profile.main.sku_name
  enabled             = true
  mode                = "Prevention"

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "main" {
  name                     = "waf-policy-link"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.main.id

      association {
        patterns_to_match = ["/*"]
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.main.id
        }
      }
    }
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "main" {
  name                     = "og-aks"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  load_balancing {}

  health_probe {
    protocol            = "Https"
    request_type        = "GET"
    path                = "/health"
    interval_in_seconds = 30
  }
}
