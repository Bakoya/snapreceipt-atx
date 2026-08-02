variable "service_name" {
  description = "Short service identifier used in the role name (e.g. core-backend)"
}
variable "account_id" {
  description = "Account the role lives in - trusted as the sole principal that can assume it"
}
variable "repository_arn" {
  description = "ECR repository ARN this role is scoped to push to"
}
variable "tags" {}
