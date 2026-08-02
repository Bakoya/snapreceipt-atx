resource "aws_lb_target_group" "ecs_target_group" {
  name        = "${var.ecs_family}-${var.env}-${var.stage_name}-tg-${var.deployment_type}"
  port        = var.ecs_tg_port
  protocol    = var.tg_protocol
  target_type = "ip"
  vpc_id      = var.vpc_id

  dynamic "health_check" {
    for_each = var.health_check_protocol == "TCP" ? [] : [1]
    content {
      path                = var.health_path
      port                = var.ecs_tg_port
      protocol            = var.health_check_protocol
      healthy_threshold   = 5
      unhealthy_threshold = 2
      interval            = 30
      timeout             = 29
      matcher             = var.health_matcher
    }
  }

  tags = var.tags
}
