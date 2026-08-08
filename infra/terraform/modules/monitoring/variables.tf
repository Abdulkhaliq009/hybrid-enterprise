variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "alert_email" { type = string }

variable "log_retention_days" {
  type    = number
  default = 30
}

variable "tags" {
  type    = map(string)
  default = {}
}
