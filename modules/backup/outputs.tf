output "vault_name" {
  value = aws_backup_vault.main.name
}

output "plan_id" {
  value = aws_backup_plan.main.id
}
