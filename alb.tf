module "alb" {
  source = "./modules/alb"

  cust_name         = var.cust_name
  env               = var.env
  account_id        = var.account_id
  vpc_id            = local.vpc_id
  alb_sg_id         = local.alb_sg_id
  public_subnet_ids = local.public_subnets
  certificate_arn   = var.certificate_arn
  tags              = local.tags
}
