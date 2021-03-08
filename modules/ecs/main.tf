resource "aws_ecs_cluster" "main"{
  name = "nginx-fargate-test-cluster"
}

resource "aws_ecs_service" "main" {
  name = "nginx-fargate-test"
  cluster         = aws_ecs_cluster.main.arn
  task_definition = aws_ecs_task_definition.app_definition.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_sec_group.id]
    subnets          = var.vpc_private_subnets_ids.*
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.fargate_target_group.arn
    container_name   = "nginx-test-app" #herre
    container_port   = 80
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role]
}

resource "aws_ecs_task_definition" "app_definition" {
  family                   = "nginx-fargate-test-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = templatefile("${path.module}/app.json.tpl" ,{
    fargate_cpu    = var.fargate_cpu
    fargate_memory = var.fargate_memory
  })#here
}
