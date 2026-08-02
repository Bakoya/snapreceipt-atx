resource "aws_ecr_repository" "ecr_registry" {
  name                 = var.registry_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.tags
}

data "aws_iam_policy_document" "ecr_repo_policy" {
  statement {
    sid    = "ecr policy"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${var.account_id}", "${var.devops_account_id}"]
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchDeleteImage",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DeleteLifecyclePolicy",
      "ecr:DeleteRepository",
      "ecr:DeleteRepositoryPolicy",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:GetRepositoryPolicy",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:PutLifecyclePolicy",
      "ecr:SetRepositoryPolicy",
      "ecr:StartLifecyclePolicyPreview",
      "ecr:UploadLayerPart"
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr-repo" {
  repository = aws_ecr_repository.ecr_registry.name
  policy     = data.aws_iam_policy_document.ecr_repo_policy.json
}
