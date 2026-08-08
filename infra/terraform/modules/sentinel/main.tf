resource "azurerm_sentinel_log_analytics_workspace_onboarding" "main" {
  workspace_id = var.log_analytics_workspace_id
}

resource "azurerm_sentinel_alert_rule_scheduled" "brute_force" {
  name                       = "brute-force-auth"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Brute-force authentication attempts"
  description                = "More than 10 failed Windows logons from a single source in 1 hour"
  severity                   = "Medium"
  enabled                    = true
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  tactics                    = ["CredentialAccess"]

  query = <<-QUERY
    SecurityEvent
    | where EventID == 4625
    | summarize FailedAttempts = count(), Accounts = make_set(Account) by IpAddress, bin(TimeGenerated, 1h)
    | where FailedAttempts > 10
  QUERY

  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

resource "azurerm_sentinel_alert_rule_scheduled" "suspicious_powershell" {
  name                       = "suspicious-powershell"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Suspicious PowerShell execution"
  description                = "Encoded or download-cradle PowerShell commands on Windows Server"
  severity                   = "High"
  enabled                    = true
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  tactics                    = ["Execution"]

  query = <<-QUERY
    SecurityEvent
    | where EventID == 4688
    | where Process has "powershell.exe"
    | where CommandLine has_any ("-enc", "-encodedcommand", "downloadstring", "iex", "invoke-expression", "bypass")
    | project TimeGenerated, Computer, Account, CommandLine
  QUERY

  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

resource "azurerm_sentinel_alert_rule_scheduled" "privileged_activity" {
  name                       = "privileged-account-activity"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Privileged group membership change"
  description                = "User added to a privileged AD group (Domain Admins, Enterprise Admins)"
  severity                   = "High"
  enabled                    = true
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  tactics                    = ["PrivilegeEscalation"]

  query = <<-QUERY
    SecurityEvent
    | where EventID in (4728, 4732, 4756)
    | where TargetUserName has_any ("Domain Admins", "Enterprise Admins", "Administrators")
    | project TimeGenerated, Computer, SubjectAccount, TargetUserName, MemberName
  QUERY

  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}

resource "azurerm_sentinel_alert_rule_scheduled" "resource_creation" {
  name                       = "unexpected-resource-creation"
  log_analytics_workspace_id = var.log_analytics_workspace_id
  display_name               = "Unexpected Azure resource creation"
  description                = "Resources created outside business hours"
  severity                   = "Low"
  enabled                    = true
  query_frequency            = "PT1H"
  query_period               = "PT1H"
  tactics                    = ["Impact"]

  query = <<-QUERY
    AzureActivity
    | where OperationNameValue endswith "write"
    | where ActivityStatusValue == "Success"
    | extend hour = hourofday(TimeGenerated)
    | where hour < 6 or hour > 22
    | project TimeGenerated, Caller, OperationNameValue, ResourceGroup
  QUERY

  trigger_operator  = "GreaterThan"
  trigger_threshold = 0

  depends_on = [azurerm_sentinel_log_analytics_workspace_onboarding.main]
}
