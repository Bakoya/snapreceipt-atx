variable "cust_name" {}

variable "env" {}

variable "region" {}

variable "account_id" {}
variable "deploy_role" {}
variable "devops_account_id" {}

variable "certificate_arn" {
  description = "Acm certificate arn for the alb https listener; leave empty until a certificate is issued"
  default     = ""
}

variable "ecs_app_container_port" {
  description = "Default container port for ecs services fronted by the alb"
  default     = 8080
}

variable "stage_name" {
  description = "Deployment stage tag used in ecs resource names (e.g. v1)"
  default     = "v1"
}

variable "scalable_dimension" {
  description = "App Auto Scaling scalable dimension for ecs services"
  default     = "ecs:service:DesiredCount"
}

variable "service_namespace" {
  description = "App Auto Scaling service namespace for ecs services"
  default     = "ecs"
}

variable "policy_type" {
  description = "App Auto Scaling policy type for ecs service scaling policies"
  default     = "StepScaling"
}

variable "vpc_cidr" {}

variable "azs" {}

variable "private_subnets" {}

variable "public_subnets" {}

variable "database_subnets" {
  default = []
}

variable "enable_nat_gateway" {}

variable "create_igw" {
  default = true
}

variable "single_nat_gateway" {
  default = true
}