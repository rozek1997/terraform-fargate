resource "aws_ecs_cluster" "app_cluster" {
  name = "${var.application_name}-${terraform.workspace}"

  capacity_providers = terraform.workspace != "prod" ? ["FARGATE", "FARGATE_SPOT"] : ["FARGATE"]
  tags = local.tags
}

module "api" {
  source           = "./api"
  module_setup     = local.module_values
  alb_target_group = var.api_target_group
  app_log_group    = aws_cloudwatch_log_group.cc_log_group["api"]
  app_log_stream   = aws_cloudwatch_log_stream.cc_log_stream["api"]
}

module "cms" {
  source           = "./cms"
  module_setup     = local.module_values
  alb_target_group = var.cms_target_group
  app_log_group    = aws_cloudwatch_log_group.cc_log_group["cms"]
  app_log_stream   = aws_cloudwatch_log_stream.cc_log_stream["cms"]
}

module "worker" {
  source         = "./worker"
  module_setup   = local.module_values
  app_log_group  = aws_cloudwatch_log_group.cc_log_group["worker"]
  app_log_stream = aws_cloudwatch_log_stream.cc_log_stream["worker"]
}

module "beat" {
  source         = "./beat"
  module_setup   = local.module_values
  app_log_group  = aws_cloudwatch_log_group.cc_log_group["beat"]
  app_log_stream = aws_cloudwatch_log_stream.cc_log_stream["beat"]
}

