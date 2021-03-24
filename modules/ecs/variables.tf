locals {
  module_values = {
    aws_region              = var.aws_region
    account_id              = var.account_id
    application_name        = var.application_name
    ecr_repo_name           = var.ecr_repo_name
    launch_type             = var.launch_type
    cluster                 = aws_ecs_cluster.app_cluster
    vpc_id                  = var.vpc_id
    private_subnet_ids      = var.private_subnet_ids
    public_subnet_ids       = var.public_subnet_ids
    port_mappings           = var.open_ports
    security_group_ids      = [aws_security_group.ecs_default.id]
    ecs_task_execution_role = aws_iam_role.ecs_task_execution
    ecs_task_role           = aws_iam_role.ecs_task
    ssm_secrets             = var.ssm_secrets
    static_env_vars         = local.static_env_vars
    template_file           = "${path.cwd}/${path.module}/template/task_definition.json.tpl"
    image_url               = "${var.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.ecr_repo_name}:${var.cc_api_image_tag}"
  }

  static_env_vars = {
    ENVIRONMENT                = terraform.workspace
    AWS_PRIVATE_BUCKET_NAME    = "cc-private-storage-${terraform.workspace}"                                                     #import this to s3 module
    AWS_SQS_WEBHOOK_QUEUE      = "https://sqs.${var.aws_region}.amazonaws.com/${var.account_id}/webhooks-${terraform.workspace}" #import this to sqs module
    AWS_STORAGE_BUCKET_NAME    = var.aws_storage_bucket_name
    AWS_TEMP_BUCKET_NAME       = var.aws_temp_bucket_name
    CLOUDFRONT_DOMAIN          = var.cloudfront_domain
    CMS_SESSION_EXPIRY_MINUTES = 1440
  }

  tags = {
    Environment = terraform.workspace
  }
}

variable "service_names" {
  type    = list(string)
  default = ["api", "cms", "worker", "beat"]
}

# General
variable "aws_region" {}

variable "account_id" {}

variable "application_name" {
  description = "Name of the application"
}

variable "ecr_repo_name" {
  default = "marek_testing_repo"
}

variable "cc_api_image_tag" {}


variable "launch_type" {
  default = "FARGATE"
}

# VPC
variable "vpc_id" {
  description = "VPC ID. That will differ based on chosen workspace"
}

variable "vpc_cidr"{}

variable "private_subnet_ids" {}
variable "public_subnet_ids" {}

variable "open_ports" {
  type = map(number)
  default = {
    UWSGI_PORT = 8080
  }
}

#alb

variable "api_target_group" {}
variable "cms_target_group" {}

# CloudFront
variable "cloudfront_domain" {}
//# S3
variable "aws_temp_bucket_name" {}
variable "aws_storage_bucket_name" {}
variable "creds_bucket" {}

# Policies
//
//variable "s3_policy_arn" {}
//variable "sns_policy_arn" {}
//variable "sqs_policy_arn" {}

variable "ssm_secrets" {
  type = list(string)
  default = [
    "terraform_test"
  ]

}


