variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "aks_secrets_identity" { type = string }
variable "private_endpoint_subnet_id" { type = string }
variable "keyvault_dns_zone_id" { type = string }
variable "db_user" { type = string }

variable "db_password" {
  type      = string
  sensitive = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
