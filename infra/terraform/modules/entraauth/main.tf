data "azuread_client_config" "current" {}

resource "random_uuid" "scope_id" {}

resource "azuread_application" "api" {
  display_name = var.app_name

  api {
    requested_access_token_version = 2

    oauth2_permission_scope {
      admin_consent_description  = "Access the hybrid API"
      admin_consent_display_name = "Access ${var.app_name}"
      enabled                    = true
      id                         = random_uuid.scope_id.result
      type                       = "User"
      value                      = "api.access"
    }
  }
}

resource "azuread_service_principal" "api" {
  client_id = azuread_application.api.client_id
}
