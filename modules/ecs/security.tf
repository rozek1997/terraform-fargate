resource "aws_security_group" "ecs_default" {
  name        = join("-", ["ecs-sg", var.application_name, terraform.workspace, "default"])
  description = "Crowdcomms API Default Security Group for Fargate Containers - ${terraform.workspace}"
  vpc_id      = var.vpc_id

  # Outbound traffic
  egress {
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = var.open_ports["UWSGI_PORT"]
    protocol    = "tcp"
    to_port     = var.open_ports["UWSGI_PORT"]
    cidr_blocks = [var.vpc_cidr]
    description = "VPC access on port 8080"
  }

  tags = local.tags

}