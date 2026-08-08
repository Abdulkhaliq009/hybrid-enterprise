variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }
variable "aks_subnet_id" { type = string }
variable "acr_id" { type = string }
variable "log_analytics_workspace_id" { type = string }

variable "node_count" {
  type    = number
  default = 2
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "min_nodes" {
  type    = number
  default = 1
}

variable "max_nodes" {
  type    = number
  default = 4
}

variable "enable_spot_pool" {
  type    = bool
  default = false
}

variable "tags" {
  type    = map(string)
  default = {}
}
