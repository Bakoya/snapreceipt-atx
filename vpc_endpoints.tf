module "vpc_endpoint" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.21.0"

  vpc_id = module.vpc.vpc_id

  endpoints = merge({
    dynamodb = {
      service         = "dynamodb"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      policy          = data.aws_iam_policy_document.vpc_endpoint_policy.json
      tags            = merge(local.tags, tomap({ "Name" = "${var.cust_name}-vpc-endpoint-dynamodb" }))
    },
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      policy          = data.aws_iam_policy_document.vpc_endpoint_policy.json
      tags            = merge(local.tags, tomap({ "Name" = "${var.cust_name}-vpc-endpoint-s3" }))
    },
    ssm = {
      service             = "ssm"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
      private_dns_enabled = true
      tags                = merge(local.tags, tomap({ "Name" = "${var.cust_name}-vpc-endpoint-ssm" }))
    },
    ssmmessages = {
      service             = "ssmmessages"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
      private_dns_enabled = true
      tags                = merge(local.tags, tomap({ "Name" = "${var.cust_name}-vpc-endpoint-ssmmessages" }))
    },
    ec2messages = {
      service             = "ec2messages"
      service_type        = "Interface"
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
      private_dns_enabled = true
      tags                = merge(local.tags, tomap({ "Name" = "${var.cust_name}-vpc-endpoint-ec2messages" }))
    }
  })
}

# Security group for SSM VPC endpoints
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.cust_name}-vpc-endpoint-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for SSM VPC endpoints"

  ingress {
    description = "HTTPS from private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.private_subnets
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, tomap({ "Name" = "${var.cust_name}-vpc-endpoint-sg" }))
}

data "aws_iam_policy_document" "vpc_endpoint_policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    # Restrict endpoint usage to principals within this account - an open
    # actions/resources policy with no principal restriction at all defeats
    # the point of having an endpoint policy (it's otherwise usable by anyone
    # who can route through the endpoint).
    condition {
      test     = "StringEquals"
      variable = "aws:PrincipalAccount"
      values   = [var.account_id]
    }
  }
}
