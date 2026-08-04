# ECR
# core-backend - disabled alongside service-core-backend.tf.disabled / ecr.tf.disabled.
# Restore together if reinstated.
# output "core_backend_ecr_repository_url" {
#   value = module.core_backend_registry.repository_url
# }
#
# output "core_backend_ecr_push_role_arn" {
#   value       = module.core_backend_push_role.role_arn
#   description = "Give this to whoever the customer designates to push images - they need sts:AssumeRole granted on it from their side"
# }

output "snapreceipt_ecr_repository_url" {
  value = module.snapreceipt_registry.repository_url
}

output "snapreceipt_ecr_push_role_arn" {
  value       = module.snapreceipt_push_role.role_arn
  description = "Give this to whoever needs to push images - they need sts:AssumeRole granted on it from their side"
}

output "snapreceipt_service_name" {
  value = module.snapreceipt_service.ecs_service_name
}

output "snapreceipt_target_group_blue_arn" {
  value = module.snapreceipt_tg_blue.ecs_target_group_arn
}

output "snapreceipt_target_group_green_arn" {
  value = module.snapreceipt_tg_green.ecs_target_group_arn
}

output "snapreceipt_dynamodb_table_users" {
  value = aws_dynamodb_table.snapreceipt_users.name
}

output "snapreceipt_dynamodb_table_receipts" {
  value = aws_dynamodb_table.snapreceipt_receipts.name
}

output "snapreceipt_s3_bucket" {
  value = aws_s3_bucket.snapreceipt_uploads.id
}

# ECS
output "ecs_cluster_name" {
  value = module.ecs_cluster.cluster_name
}

output "ecs_cluster_arn" {
  value = module.ecs_cluster.cluster_arn
}

# ALB / WAF
output "alb_arn" {
  value = module.alb.alb_arn
}

output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_https_listener_arn" {
  value       = module.alb.https_listener_arn
  description = "Null until certificate_arn is set"
}

output "alb_http_listener_arn" {
  value       = module.alb.http_listener_arn
  description = "Null once certificate_arn is set (replaced by the 80->443 redirect)"
}

# WAF - disabled alongside waf.tf.disabled. Restore together if reinstated.
# output "waf_web_acl_arn" {
#   value = module.waf.web_acl_arn
# }

# ECR endpoints
output "ecr_api_endpoint_id" {
  value = module.ecr_api_endpoint.endpoint_id
}

output "ecr_dkr_endpoint_id" {
  value = module.ecr_dkr_endpoint.endpoint_id
}

# RDS - disabled alongside rds.tf..disabled. Restore together if reinstated.
# output "simplex_db_endpoint" {
#   value = module.simplex_db.endpoint
# }
#
# output "simplex_db_secret_arn" {
#   value = module.simplex_db.secret_arn
# }
#
# output "pensions_db_endpoint" {
#   value = module.pensions_db.endpoint
# }
#
# output "pensions_db_secret_arn" {
#   value = module.pensions_db.secret_arn
# }
#
# output "rds_sg_id" {
#   value = aws_security_group.rds_sg.id
# }

# EFS - disabled alongside efs.tf..disabled. Restore together if reinstated.
# output "efs_id" {
#   value = module.efs.efs_id
# }
#
# output "efs_sg_id" {
#   value = aws_security_group.efs_sg.id
# }

# Backup - disabled alongside backup.tf.disabled (only backed up simplex_db/pensions_db,
# which are disabled too). Restore together if any of these are reinstated.
# output "backup_vault_name" {
#   value = module.backup.vault_name
# }
#
# output "backup_plan_id" {
#   value = module.backup.plan_id
# }

# ECS service - core-backend - disabled alongside service-core-backend.tf.disabled.
# Restore together if reinstated (or repurposed as the format for a new snapreceipt service).
# output "core_backend_service_name" {
#   value = module.core_backend_service.ecs_service_name
# }
#
# output "core_backend_target_group_blue_arn" {
#   value = module.core_backend_tg_blue.ecs_target_group_arn
# }
#
# output "core_backend_target_group_green_arn" {
#   value = module.core_backend_tg_green.ecs_target_group_arn
# }

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "database_subnets" {
  value = module.vpc.database_subnets
}

output "database_subnet_group_name" {
  value = module.vpc.database_subnet_group_name
}

output "private_subnet_cidr" {
  value = module.vpc.private_subnet_cidr
}

output "public_subnet_cidr" {
  value = module.vpc.public_subnet_cidr
}

output "vpc_endpoints" {
  value = module.vpc_endpoint.endpoints
}

# Security Groups
output "app_sg_id" {
  value       = aws_security_group.app_sg.id
  description = "App security group ID"
}

output "alb_sg_id" {
  value       = aws_security_group.alb_sg.id
  description = "ALB security group ID"
}

# KMS
output "data_encryption_key_arn" {
  value       = aws_kms_key.data_encryption.arn
  description = "KMS key ARN for data encryption"
}

# CloudTrail - disabled 2026-07-xx, redundant with Control Tower's org trail.
# Restore alongside cloudtrail.tf.disabled -> cloudtrail.tf if reinstated.
# output "cloudtrail_arn" {
#   value       = aws_cloudtrail.main.arn
#   description = "CloudTrail ARN"
# }

# VPC Flow Logs
output "vpc_flow_log_id" {
  value       = aws_flow_log.main.id
  description = "VPC Flow Log ID"
}

# CloudWatch
output "sns_alerts_topic_arn" {
  value       = aws_sns_topic.alerts.arn
  description = "SNS topic ARN for security alerts"
}

output "cloudwatch_dashboard_name" {
  value       = aws_cloudwatch_dashboard.main.dashboard_name
  description = "CloudWatch dashboard name"
}

# Secrets Manager
output "api_keys_secret_arn" {
  value       = aws_secretsmanager_secret.api_keys.arn
  description = "Secrets Manager ARN for API keys"
}

output "secrets_read_policy_arn" {
  value       = aws_iam_policy.secrets_read.arn
  description = "IAM policy ARN for reading secrets"
}
