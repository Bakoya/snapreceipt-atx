variable "cust_name" {}
variable "env" {}
variable "account_id" {}
variable "vpc_id" {}
variable "alb_sg_id" {}
variable "public_subnet_ids" {}

variable "certificate_arn" {
  default = ""
}

variable "tags" {}
