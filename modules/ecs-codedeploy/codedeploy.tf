resource "aws_codedeploy_app" "codedeploy" {
  compute_platform = "ECS"
  name             = "${var.cust_name}-${var.ecs_family}-codedeploy_app"
  tags             = merge(var.tags, tomap({ "Name" = "${var.cust_name}-${var.ecs_family}-codedeploy_app" }))
}

resource "aws_codedeploy_deployment_group" "example" {
  app_name               = aws_codedeploy_app.codedeploy.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name  = "${var.cust_name}-${var.ecs_family}-${var.env}-dg"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = var.cluster_name
    service_name = var.service_name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = var.aws_lb_listener_arns
      }
      test_traffic_route {
        listener_arns = var.aws_lb_listener_8443_arns
      }

      target_group {
        name = var.target_group_name_blue
      }

      target_group {
        name = var.target_group_name_green
      }
    }
  }

  tags = merge(var.tags, tomap({ "Name" = "${var.cust_name}-${var.ecs_family}-${var.env}-dg" }))
}
