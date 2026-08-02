# Same-region baseline backup (Phase 4 of the project plan). Cross-region DR
# copy is intentionally not included here - that's the disputed/optional DR
# scope from the SOW, not baseline backup.
resource "aws_backup_vault" "main" {
  name        = "${var.cust_name}-backup-vault-${var.env}"
  kms_key_arn = var.kms_key_arn
  tags        = merge(var.tags, tomap({ "Name" = "${var.cust_name}-backup-vault-${var.env}" }))
}

resource "aws_iam_role" "backup" {
  name = "${var.cust_name}-backup-role-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "backup.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_plan" "main" {
  name = "${var.cust_name}-backup-plan-${var.env}"

  rule {
    rule_name         = "daily-30-day-retention"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 1 * * ? *)"

    lifecycle {
      delete_after = 30
    }
  }

  tags = var.tags
}

resource "aws_backup_selection" "this" {
  name         = "${var.cust_name}-backup-selection-${var.env}"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.main.id

  resources = var.resource_arns
}
