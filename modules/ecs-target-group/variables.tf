variable "env" {}
variable "stage_name" {}
variable "ecs_family" {}
variable "vpc_id" {}
variable "health_path" { default = "" }
variable "tags" {}
variable "ecs_service_id" {}
variable "deployment_type" {}
variable "ecs_tg_port" {}
variable "tg_protocol" {}
variable "health_check_protocol" { default = "HTTP" }
variable "health_matcher" {
  description = "Health check status code matcher (e.g. \"200\" or a range like \"200-499\"). ALB target groups only support HTTP/HTTPS health checks - there's no true TCP/port-only check like on an NLB, so a wide range is the closest equivalent when the real health path isn't known yet."
  default     = "200"
}
