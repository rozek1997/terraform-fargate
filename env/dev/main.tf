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
  profile = "sofomo"
}

module "vpc" {
  source = "../../modules/vpc"
}

module "alb" {
  source = "../../modules/alb"
//  loadbalancer_certificate_arn = ""
  public_subnets_ids = module.vpc.vpc_public_subnets_ids
  vpc_id = module.vpc.vpc.id
}

//module "ecr" {
//   source = "../../modules/ecr"
//   repository_name = "marek_testing_repo"
//}

module "ecs" {
  source = "../../modules/ecs"
  application_name = "crowdcomms_test"
  aws_region = var.region
  account_id = var.account_id
  api_target_group = module.alb.api_target_group
  aws_storage_bucket_name = "aws_storage_bucket_name"
  aws_temp_bucket_name = "aws_temp_bucket_name"
  cc_api_image_tag = var.cc_api_image_tag
  cloudfront_domain = "aws_clodfront_domain"
  cms_target_group = module.alb.cms_target_group
  creds_bucket = "creds_bucket"
  private_subnet_ids = module.vpc.vpc_private_subnets_ids
  public_subnet_ids = module.vpc.vpc_public_subnets_ids
  vpc_id = module.vpc.vpc.id
  vpc_cidr = module.vpc.vpc.cidr_block
//  s3_policy_arn = "
//  sns_policy_arn = ""
//  sqs_policy_arn = ""

}
