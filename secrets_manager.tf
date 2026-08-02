# Secrets Manager for secure storage and rotation of credentials and API keys

# Application API keys
resource "aws_secretsmanager_secret" "api_keys" {
  name        = "${var.cust_name}/${var.env}/api-keys"
  description = "Application API keys"
  kms_key_id  = aws_kms_key.data_encryption.arn

  tags = merge(local.tags, tomap({ "Name" = "${var.cust_name}-${var.env}-api-keys" }))
}

resource "aws_secretsmanager_secret_version" "api_keys" {
  secret_id = aws_secretsmanager_secret.api_keys.id
  secret_string = jsonencode({
    placeholder = "update-with-actual-api-keys"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

# IAM policy for EC2 instances to read secrets
resource "aws_iam_policy" "secrets_read" {
  name        = "${var.cust_name}-${var.env}-secrets-read"
  description = "Allow EC2 instances to read secrets from Secrets Manager"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.api_keys.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = [aws_kms_key.data_encryption.arn]
      }
    ]
  })
  tags = local.tags
}
