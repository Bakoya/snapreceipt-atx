variable "cust_name" {}
variable "env" {}
variable "kms_key_arn" {}
variable "resource_arns" {
  type        = list(string)
  description = "ARNs of resources (e.g. RDS instances) to back up"
}
variable "tags" {}
