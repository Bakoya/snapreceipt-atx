# SnapReceipt FastAPI service - real service definition, following the same
# blue/green + autoscaling format as service-core-backend.tf.disabled.
#
# Scope for this test: health-check only (see AskUserQuestion 2026-08-03).
# The service is wired to serve traffic and pass ALB health checks on /health,
# which needs no AWS calls. DynamoDB/S3/Textract wiring (env vars, task role
# permissions) is deliberately NOT included yet - /signup, /receipts, and
# /spending will 500 until that's added. This is enough to validate blue/green
# deployment mechanics (does traffic actually shift from blue to green cleanly).
#
# Image: initially points at nothing pushed yet - this task definition will
# start failing to pull until the AWS-Transform-built image is retagged into
# snapreceipt_registry below (see project_snapreceipt_atx_bluegreen_test memory
# for the promotion command once this is applied and the registry URI exists).

locals {
  snapreceipt_service = {
    ecs_family     = "snapreceipt-api"
    registry_name  = "${var.cust_name}-snapreceipt-api"
    container_port = 8000
  }
}

module "snapreceipt_registry" {
  source            = "./modules/ecr"
  cust_name         = var.cust_name
  account_id        = var.account_id
  devops_account_id = var.devops_account_id
  registry_name     = local.snapreceipt_service.registry_name
  tags              = merge(local.tags, tomap({ "Name" = local.snapreceipt_service.registry_name }))
}

# Lets the customer's team push images to this repo without Datamellon needing to know or
# manage which of their identities does it - see modules/ecr-push-role for the design rationale.
module "snapreceipt_push_role" {
  source         = "./modules/ecr-push-role"
  service_name   = local.snapreceipt_service.ecs_family
  account_id     = var.account_id
  repository_arn = module.snapreceipt_registry.repository_arn
  tags           = local.tags
}

module "snapreceipt_taskdef" {
  source     = "./modules/ecs-taskdef"
  env        = var.env
  cust_name  = var.cust_name
  ecs_family = local.snapreceipt_service.ecs_family
  stage_name = var.stage_name
  taskcpu    = 512
  taskmem    = 1024
  tags       = merge(local.tags, tomap({ "Name" = "${local.snapreceipt_service.ecs_family}-${var.env}-ecs-task" }))
  role_tags  = merge(local.tags, tomap({ "Name" = "${local.snapreceipt_service.ecs_family}-${var.env}-ecs-role" }))

  container_definitions = jsonencode([
    {
      "name"      = "${local.snapreceipt_service.ecs_family}-${var.env}-${var.stage_name}",
      "image"     = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${local.snapreceipt_service.registry_name}:${local.snapreceipt_service.ecs_family}-${var.env}-${var.stage_name}",
      "essential" = true,
      "portMappings" = [
        {
          "protocol"      = "tcp",
          "containerPort" = local.snapreceipt_service.container_port,
          "hostPort"      = local.snapreceipt_service.container_port
        }
      ],
      "environment" = [],
      "secrets"     = [],
      "logConfiguration" = {
        "logDriver" = "awslogs",
        "options" = {
          "awslogs-create-group"  = "true",
          "awslogs-group"         = "ecs/fargate/service/${var.env}/${local.snapreceipt_service.ecs_family}-service",
          "awslogs-region"        = var.region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  # Minimal for health-check-only scope: just log delivery. Add dynamodb/s3/textract
  # permissions here (scoped to specific table/bucket ARNs) once functional depth is added.
  custom_policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LogGroupPermissions",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    }
  ]
}
EOF

  depends_on = [module.snapreceipt_registry]
}

module "snapreceipt_tg_blue" {
  source          = "./modules/ecs-target-group"
  env             = var.env
  ecs_family      = local.snapreceipt_service.ecs_family
  stage_name      = var.stage_name
  vpc_id          = local.vpc_id
  health_path     = "/health"
  health_matcher  = "200"
  ecs_tg_port     = local.snapreceipt_service.container_port
  tg_protocol     = "HTTP"
  deployment_type = "blue"
  ecs_service_id  = module.snapreceipt_service.ecs_service_id
  tags            = merge(local.tags, tomap({ "Name" = "${local.snapreceipt_service.ecs_family}-${var.env}-${var.stage_name}-tg-blue" }))
}

module "snapreceipt_tg_green" {
  source          = "./modules/ecs-target-group"
  env             = var.env
  ecs_family      = local.snapreceipt_service.ecs_family
  stage_name      = var.stage_name
  vpc_id          = local.vpc_id
  health_path     = "/health"
  health_matcher  = "200"
  ecs_tg_port     = local.snapreceipt_service.container_port
  tg_protocol     = "HTTP"
  ecs_service_id  = module.snapreceipt_service.ecs_service_id
  deployment_type = "green"
  tags            = merge(local.tags, tomap({ "Name" = "${local.snapreceipt_service.ecs_family}-${var.env}-${var.stage_name}-tg-green" }))
}

module "snapreceipt_service" {
  source                 = "./modules/ecs-service"
  env                    = var.env
  cust_name              = var.cust_name
  service_name           = local.snapreceipt_service.ecs_family
  cluster_id             = module.ecs_cluster.cluster_name
  task_definition_arn    = module.snapreceipt_taskdef.task_arn
  desired_counts         = 1
  enable_execute_command = true
  target_group_arn       = module.snapreceipt_tg_blue.ecs_target_group_arn
  subnet_ids             = local.private_subnets
  security_groups        = [local.app_sg_id]
  container_port         = local.snapreceipt_service.container_port
  assign_public_ip       = false
  container_name         = module.snapreceipt_taskdef.container_name
  tags                   = merge(local.tags, tomap({ "Name" = "${var.cust_name}-${local.snapreceipt_service.ecs_family}-ecs-service-${var.env}" }))
  depends_on             = [module.ecs_cluster, module.snapreceipt_taskdef]
}

module "snapreceipt_asg" {
  source                 = "./modules/ecs-auto_scaling"
  env                    = var.env
  cluster_name           = module.ecs_cluster.cluster_name
  service_name           = module.snapreceipt_service.ecs_service_name
  ecs_family             = local.snapreceipt_service.ecs_family
  stage_name             = var.stage_name
  max_capacity           = 4
  min_capacity           = 1
  cluster_and_service_id = "service/${module.ecs_cluster.cluster_name}/${module.snapreceipt_service.ecs_service_name}"
  scalable_dimension     = var.scalable_dimension
  service_namespace      = var.service_namespace
  policy_type            = var.policy_type
  target_value           = 50
  tags                   = local.tags
}

module "snapreceipt_codedeploy" {
  source                    = "./modules/ecs-codedeploy"
  env                       = var.env
  cust_name                 = var.cust_name
  cluster_name              = module.ecs_cluster.cluster_name
  service_name              = module.snapreceipt_service.ecs_service_name
  aws_lb_listener_arns      = [var.certificate_arn == "" ? module.alb.http_listener_arn : module.alb.https_listener_arn]
  aws_lb_listener_8443_arns = [var.certificate_arn == "" ? module.alb.http_test_listener_arn : module.alb.https_test_listener_arn]
  target_group_name_blue    = module.snapreceipt_tg_blue.ecs_target_group_name
  target_group_name_green   = module.snapreceipt_tg_green.ecs_target_group_name
  ecs_family                = local.snapreceipt_service.ecs_family
  tags                      = local.tags
}

# Only service on this ALB for now - catch-all rather than a path prefix like
# service-core-backend.tf.disabled used, since SnapReceipt's real routes
# (/signup, /receipts, /spending, /health) don't share a common prefix.
module "snapreceipt_alb_rule_http_blue" {
  count            = var.certificate_arn == "" ? 1 : 0
  source           = "./modules/alb-listener-rule"
  cust_name        = var.cust_name
  service_name     = local.snapreceipt_service.ecs_family
  env              = var.env
  listener_arn     = module.alb.http_listener_arn
  target_group_arn = module.snapreceipt_tg_blue.ecs_target_group_arn
  path_patterns    = ["/*"]
  priority         = 1
  tags             = local.tags
}

module "snapreceipt_alb_rule_http_green" {
  count            = var.certificate_arn == "" ? 1 : 0
  source           = "./modules/alb-listener-rule"
  cust_name        = var.cust_name
  service_name     = local.snapreceipt_service.ecs_family
  env              = var.env
  listener_arn     = module.alb.http_test_listener_arn
  target_group_arn = module.snapreceipt_tg_green.ecs_target_group_arn
  path_patterns    = ["/*"]
  priority         = 1
  tags             = local.tags
}

module "snapreceipt_alb_rule_https_blue" {
  count            = var.certificate_arn != "" ? 1 : 0
  source           = "./modules/alb-listener-rule"
  cust_name        = var.cust_name
  service_name     = local.snapreceipt_service.ecs_family
  env              = var.env
  listener_arn     = module.alb.https_listener_arn
  target_group_arn = module.snapreceipt_tg_blue.ecs_target_group_arn
  path_patterns    = ["/*"]
  priority         = 1
  tags             = local.tags
}

module "snapreceipt_alb_rule_https_green" {
  count            = var.certificate_arn != "" ? 1 : 0
  source           = "./modules/alb-listener-rule"
  cust_name        = var.cust_name
  service_name     = local.snapreceipt_service.ecs_family
  env              = var.env
  listener_arn     = module.alb.https_test_listener_arn
  target_group_arn = module.snapreceipt_tg_green.ecs_target_group_arn
  path_patterns    = ["/*"]
  priority         = 1
  tags             = local.tags
}
