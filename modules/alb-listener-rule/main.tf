resource "aws_lb_listener_rule" "alb-service-listener-rule" {
  listener_arn = var.listener_arn
  priority     = var.priority

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  dynamic "condition" {
    for_each = var.path_patterns != null ? [var.path_patterns] : []
    content {
      path_pattern {
        values = condition.value
      }
    }
  }

  dynamic "condition" {
    for_each = var.host_header != null ? [var.host_header] : []
    content {
      host_header {
        values = condition.value
      }
    }
  }

  lifecycle {
    ignore_changes = [action]
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.cust_name}-${var.service_name}-rule-${var.env}" }))
}
