resource "azurerm_security_center_subscription_pricing" "servers" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "sql" {
  tier          = "Standard"
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "containers" {
  tier          = "Standard"
  resource_type = "Containers"
}

resource "azurerm_security_center_subscription_pricing" "keyvault" {
  tier          = "Standard"
  resource_type = "KeyVaults"
}

resource "azurerm_security_center_contact" "main" {
  email               = var.security_contact_email
  alert_notifications = true
  alerts_to_admins    = true
}

resource "azurerm_security_center_workspace" "main" {
  scope        = "/subscriptions/${var.subscription_id}"
  workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_resource_group_policy_assignment" "require_tags" {
  name                 = "require-project-tag"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/871b6d14-10aa-478d-b590-94f262ecfa99"
  description          = "Require a project tag on all resources"
  display_name         = "Require project tag"

  parameters = jsonencode({
    tagName = { value = "project" }
  })
}
