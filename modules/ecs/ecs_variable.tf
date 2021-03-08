variable "aws_region" {

}

variable "vpc" {

}

variable "vpc_public_subnets_ids"{
  type = list

}

variable "vpc_private_subnets_ids"{
  type = list

}

variable "fargate_cpu" {
  default = 1024
}

variable "fargate_memory" {
  default = 2048
}

variable "app_count" {
  default = 2
}

variable "ecs_task_execution_role_name" {
  default = "marekECSTaskExecutionRoleName"
}
