output "task_arn" {
  value = aws_ecs_task_definition.ecs_task.arn
}

output "task_revision" {
  value = aws_ecs_task_definition.ecs_task.revision
}

output "container_name" {
  value = "${var.ecs_family}-${var.env}-${var.stage_name}"
}
