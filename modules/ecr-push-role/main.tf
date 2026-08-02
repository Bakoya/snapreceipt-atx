# Scoped to a single ECR repository - one invocation per service (see service-core-backend.tf)
# rather than one shared role across every repo, so a leaked credential only exposes one
# service's image push, not all of them. Trusts the account root, matching the same pattern
# as cicd-deployment-role: whoever the customer designates to do the push just needs
# their own identity granted sts:AssumeRole on this specific role ARN - Datamellon doesn't need
# to know or manage which identity that is.
resource "aws_iam_role" "push" {
  name = "${var.service_name}-ecr-push-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${var.account_id}:root"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = merge(var.tags, tomap({ "Name" = "${var.service_name}-ecr-push-role" }))
}

resource "aws_iam_role_policy" "push" {
  name = "${var.service_name}-ecr-push-policy"
  role = aws_iam_role.push.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRAuthToken"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*" # AWS requires this action to be unscoped - it doesn't support resource-level restriction
      },
      {
        Sid    = "ECRPushToRepository"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = var.repository_arn
      }
    ]
  })
}
