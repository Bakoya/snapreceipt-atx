resource "aws_cloudwatch_log_group" "ecs_cluster" {
  name              = "/aws/ecs/${var.cust_name}-cluster-${var.env}"
  retention_in_days = 90
  kms_key_id        = local.kms_key_arn
  tags              = merge(local.tags, tomap({ "Name" = "${var.cust_name}-ecs-cluster-log-${var.env}" }))
}

module "ecs_cluster" {
  source = "./modules/ecs-cluster"

  cust_name      = var.cust_name
  env            = var.env
  kms_key_arn    = local.kms_key_arn
  log_group_name = aws_cloudwatch_log_group.ecs_cluster.name
  tags           = local.tags
}
