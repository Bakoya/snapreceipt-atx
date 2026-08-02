# Interface endpoints so private-subnet Fargate tasks can pull images from ECR
# without routing through the NAT Gateway. Shares the vpc-endpoint SG created
# in vpc_endpoints.tf (ingress 443 from the private subnets).
module "ecr_api_endpoint" {
  source = "./modules/vpc-endpoint"

  name               = "${var.cust_name}-vpc-endpoint-ecr-api"
  vpc_id             = local.vpc_id
  service_name       = "com.amazonaws.${var.region}.ecr.api"
  subnet_ids         = local.private_subnets
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  tags               = local.tags
}

module "ecr_dkr_endpoint" {
  source = "./modules/vpc-endpoint"

  name               = "${var.cust_name}-vpc-endpoint-ecr-dkr"
  vpc_id             = local.vpc_id
  service_name       = "com.amazonaws.${var.region}.ecr.dkr"
  subnet_ids         = local.private_subnets
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  tags               = local.tags
}
