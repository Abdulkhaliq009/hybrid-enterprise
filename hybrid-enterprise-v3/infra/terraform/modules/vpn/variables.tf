variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "onprem_public_ip" { type = string }
variable "onprem_address_space" { type = string }

variable "vpn_gateway_sku" {
  type    = string
  default = "VpnGw1AZ"
}

variable "vpn_shared_key" {
  type      = string
  sensitive = true
  # No default — provide via TF_VAR_vpn_shared_key or tfvars
}

variable "tags" {
  type    = map(string)
  default = {}
}
