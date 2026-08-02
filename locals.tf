locals {
  tags = {
    Environment = var.env
    Repository  = "${var.cust_name}-resources"
  }

  vpc_name = "${var.cust_name}-vpc"

  # Previously read from a separate cs-vpc-infra state via terraform_remote_state (see
  # backend.tf history). VPC/SGs/KMS are now created directly in this repo, so these
  # point at local resources instead.
  vpc_id                     = module.vpc.vpc_id
  public_subnets             = module.vpc.public_subnets
  private_subnets            = module.vpc.private_subnets
  database_subnet_group_name = module.vpc.database_subnet_group_name
  alb_sg_id                  = aws_security_group.alb_sg.id
  app_sg_id                  = aws_security_group.app_sg.id
  kms_key_arn                = aws_kms_key.data_encryption.arn
}
