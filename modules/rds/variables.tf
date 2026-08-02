variable "identifier" {}
variable "engine" {}
variable "engine_version" {}
variable "license_model" {
  default = "license-included"
}
variable "instance_class" {}
variable "allocated_storage" {}
variable "storage_type" {
  default = "gp3"
}
variable "kms_key_arn" {}
variable "db_subnet_group_name" {}
variable "vpc_security_group_ids" {}
variable "multi_az" {
  default = true
}
variable "username" {
  default = "snapreceipt-atx_admin"
}
variable "env" {}
variable "backup_retention_period" {
  default = 30
}
variable "backup_window" {
  default = "02:00-03:00"
}
variable "maintenance_window" {
  default = "sun:03:30-sun:05:00"
}
variable "final_snapshot_identifier" {
  default = null
}
variable "tags" {}
