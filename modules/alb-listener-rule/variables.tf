variable "cust_name" {}
variable "env" {}
variable "tags" {}
variable "listener_arn" {}
variable "priority" {}
variable "target_group_arn" {}

variable "path_patterns" {
  type    = list(string)
  default = null
}

variable "host_header" {
  type    = list(string)
  default = null
}

variable "service_name" {}
