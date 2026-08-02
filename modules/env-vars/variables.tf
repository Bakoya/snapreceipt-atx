variable "service_name" {
  description = "Name of the service (e.g., jrb_agent)"
  type        = string
}

variable "ssm_base_path" {
  description = "Base SSM path prefix"
  type        = string
  default     = "/jrb_ai"
}
