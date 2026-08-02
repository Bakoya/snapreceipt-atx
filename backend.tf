provider "aws" {
  region = var.region
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/${var.deploy_role}"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    encrypt        = true
    bucket         = "ladoumi-terraform-remote-state"
    dynamodb_table = "ladoumi-terraform-locks"
    region         = "eu-west-1"
    key            = "snapreceipt-atx/{{env}}/terraform.tfstate"
    kms_key_id     = "arn:aws:kms:eu-west-1:363475792261:key/b3499b6c-52a8-42ad-bedf-4be96e5d4fc0"
  }
}

# data "terraform_remote_state" "vpc_infra" {
#   backend = "s3"

#   config = {
#     bucket = "ladoumi-terraform-remote-state"
#     key    = "cs-vpc-infra/${var.env}/terraform.tfstate"
#     region = "eu-west-1"
#   }
# }
