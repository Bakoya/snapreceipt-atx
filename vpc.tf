module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = var.vpc_cidr
  vpc_name            = local.vpc_name
  azs                 = var.azs
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  database_subnets    = var.database_subnets
  enable_nat_gateway  = var.enable_nat_gateway
  create_igw          = var.create_igw
  single_nat_gateway  = var.single_nat_gateway
  tags                = local.tags
}
