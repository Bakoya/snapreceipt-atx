module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name             = var.vpc_name
  cidr             = var.vpc_cidr
  azs              = var.azs
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  enable_nat_gateway            = var.enable_nat_gateway
  enable_vpn_gateway            = false
  create_igw                    = var.create_igw
  manage_default_network_acl    = false
  manage_default_route_table    = false
  manage_default_security_group = false
  single_nat_gateway            = var.single_nat_gateway

  tags = var.tags
}
