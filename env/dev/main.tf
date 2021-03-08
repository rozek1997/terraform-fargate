terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "default"
}

module "vpc" {
  source = "../../modules/vpc"
}

# module "ecr" {
#   source = "../../modules/ecr"
#   repository_name = "marek_testing_repo"
# }

module "ecs" {
  source = "../../modules/ecs"
  vpc = module.vpc.vpc
  vpc_public_subnets_ids = module.vpc.vpc_public_subnets_ids
  vpc_private_subnets_ids = module.vpc.vpc_private_subnets_ids
  aws_region = var.region
}
