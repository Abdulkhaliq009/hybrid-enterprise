variable "location" {
  type    = string
  default = "westeurope"
}

variable "onprem_public_ip" { type = string }
variable "onprem_address_space" { type = string }
variable "onprem_db_host" { type = string }
variable "db_user" { type = string }

variable "db_password" {
  type      = string
  sensitive = true
}

variable "alert_email" { type = string }
