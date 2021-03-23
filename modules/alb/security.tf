resource "aws_security_group" "alb" {
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = [var.open_ports["HTTP"], var.open_ports["HTTPS"]]
    iterator = port
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = var.open_ports["UWSGI_PORT"]
    to_port     = var.open_ports["UWSGI_PORT"]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
