variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "environment" { type = string }

variable "dr_location" {
  type    = string
  default = "northeurope"
}

variable "tags" {
  type    = map(string)
  default = {}
}
