output "ecs_target_group_id" {
  value = aws_lb_target_group.ecs_target_group.id
}

output "ecs_target_group_name" {
  value = aws_lb_target_group.ecs_target_group.name
}

output "ecs_target_group_arn" {
  value = aws_lb_target_group.ecs_target_group.arn
}
