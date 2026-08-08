variable "resource_group_name" { type = string }
variable "resource_group_id" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "alert_email" { type = string }

variable "monthly_budget_eur" {
  type    = number
  default = 50
}

variable "tags" {
  type    = map(string)
  default = {}
}
