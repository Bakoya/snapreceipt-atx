resource "aws_appautoscaling_target" "ecs_auto_sg" {
  max_capacity       = var.max_capacity
  min_capacity       = var.min_capacity
  resource_id        = var.cluster_and_service_id
  scalable_dimension = var.scalable_dimension
  service_namespace  = var.service_namespace
}

resource "aws_appautoscaling_policy" "ecs_asg_scale_down_policy" {
  name               = "${var.ecs_family}-${var.env}-${var.stage_name}-asg-policy"
  policy_type        = var.policy_type
  resource_id        = aws_appautoscaling_target.ecs_auto_sg.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_auto_sg.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_auto_sg.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }
}

resource "aws_appautoscaling_policy" "ecs_asg_scale_up_policy" {
  name               = "${var.ecs_family}-${var.env}-${var.stage_name}-asg-scale-up-policy"
  policy_type        = var.policy_type
  resource_id        = aws_appautoscaling_target.ecs_auto_sg.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_auto_sg.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_auto_sg.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }
}

resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  alarm_name          = "${var.ecs_family}-${var.env}-${var.stage_name}-high-cpu"
  alarm_description   = "Monitors ECS CPU Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 40

  alarm_actions = [aws_appautoscaling_policy.ecs_asg_scale_up_policy.arn]

  dimensions = {
    "ClusterName" = var.cluster_name
    "ServiceName" = var.service_name
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.ecs_family}-${var.env}-${var.stage_name}-high-cpu" }))
}

resource "aws_cloudwatch_metric_alarm" "low_cpu_alarm" {
  alarm_name          = "${var.ecs_family}-${var.env}-${var.stage_name}-low-cpu"
  alarm_description   = "Monitors ECS CPU Utilization"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = 10

  alarm_actions = [aws_appautoscaling_policy.ecs_asg_scale_down_policy.arn]

  dimensions = {
    "ClusterName" = var.cluster_name
    "ServiceName" = var.service_name
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.ecs_family}-${var.env}-${var.stage_name}-low-cpu" }))
}
