resource "aws_ecs_service" "cms_service" {
  name            = join("-", [var.module_setup.application_name, terraform.workspace, var.module_name])
  cluster         = var.module_setup.cluster.arn
  task_definition = aws_ecs_task_definition.cms_task_definition.arn
//  launch_type     = var.module_setup.launch_type

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    base = ceil(var.asg_min[terraform.workspace])
    weight = 1
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    weight = 1
  }

  network_configuration {
    security_groups  = var.module_setup.security_group_ids
    subnets          = var.module_setup.private_subnet_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group.arn
    container_name   = "crowdcomms_${var.module_name}"
    container_port   = 8080
  }

  lifecycle {
    ignore_changes = [desired_count]
  }
}


resource "aws_ecs_task_definition" "cms_task_definition" {
  family                   = join("-", [terraform.workspace, var.module_name])
  execution_role_arn       = var.module_setup.ecs_task_execution_role.arn
  task_role_arn            = var.module_setup.ecs_task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = [var.module_setup.launch_type]
  cpu                      = var.fargate_cpu[terraform.workspace]
  memory                   = var.fargate_memory[terraform.workspace]
  container_definitions = templatefile(var.module_setup.template_file, {
    account_id  = var.module_setup.account_id,
    aws_region  = var.module_setup.aws_region,
    workspace   = terraform.workspace,
    ssm_secrets = var.module_setup.ssm_secrets,
    environments = concat(
      [for env_key, env in var.module_setup.static_env_vars : { name = env_key, value = tostring(env) }],
    [for env_key, env in local.dynamic_env_vars : { name = env_key, value = tostring(env[terraform.workspace]) } if env[terraform.workspace] != null]),
    service        = var.module_name,
    image          = var.module_setup.image_url,
    service_memory = var.application_memory_reservation[terraform.workspace],
    cc_log_group   = var.app_log_group.name,
    cc_log_stream  = var.app_log_stream.name
  })

}