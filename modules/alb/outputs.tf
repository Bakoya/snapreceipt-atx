output "alb_arn" {
  value = aws_lb.main.arn
}

output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "http_listener_arn" {
  value       = try(aws_lb_listener.http[0].arn, null)
  description = "Null once certificate_arn is set (replaced by the 80->443 redirect)"
}

output "https_listener_arn" {
  value       = try(aws_lb_listener.https[0].arn, null)
  description = "Null until certificate_arn is set"
}

output "http_test_listener_arn" {
  value       = try(aws_lb_listener.http_test[0].arn, null)
  description = "Port 8080 CodeDeploy test listener. Null once certificate_arn is set."
}

output "https_test_listener_arn" {
  value       = try(aws_lb_listener.https_test[0].arn, null)
  description = "Port 8443 CodeDeploy test listener. Null until certificate_arn is set."
}

output "log_bucket_name" {
  value = aws_s3_bucket.alb_logs.id
}
