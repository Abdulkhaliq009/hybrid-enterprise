variable "environment" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "onprem_public_ip" { type = string }
variable "onprem_address_space" { type = string }
variable "onprem_db_host" { type = string }
variable "db_user" { type = string }

variable "db_password" {
  type      = string
  sensitive = true
}

variable "alert_email" { type = string }

variable "vpn_gateway_sku" {
  type    = string
  default = "VpnGw1"
}

variable "aks_node_count" {
  type    = number
  default = 2
}

variable "aks_min_nodes" {
  type    = number
  default = 1
}

variable "aks_max_nodes" {
  type    = number
  default = 4
}

variable "enable_spot_pool" {
  type    = bool
  default = false
}

variable "enable_firewall" {
  type    = bool
  default = false
}

variable "enable_asr" {
  type    = bool
  default = false
}

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "monthly_budget_eur" {
  type    = number
  default = 50
}
