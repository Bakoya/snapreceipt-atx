variable "cluster_name" { default = "" }
variable "service_name" { default = "" }
variable "aws_lb_listener_arns" { default = [] }
variable "target_group_name_blue" { default = "" }
variable "target_group_name_green" { default = "" }
variable "env" {}
variable "cust_name" {}
variable "ecs_family" {}
variable "aws_lb_listener_8443_arns" {}
variable "tags" {}
