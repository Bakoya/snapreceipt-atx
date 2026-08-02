output "ecs_service_id" {
  value = aws_ecs_service.ecs_service.id
}

output "ecs_service_name" {
  value = aws_ecs_service.ecs_service.name
}

output "ecs_service_desired_count" {
  value = aws_ecs_service.ecs_service.desired_count
}

output "ecs_service_cluster" {
  value = aws_ecs_service.ecs_service.cluster
}
