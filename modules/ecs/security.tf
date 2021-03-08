resource "aws_security_group" "alb_sec_group" {

    description = "control traffic from internet to load balancer"
    vpc_id = var.vpc.id
    dynamic "ingress" {
      for_each = [80, 443]
      iterator = port
      content {
        from_port = port.value
        to_port = port.value
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }

    dynamic "egress" {
      for_each = [80, 443]
      iterator = port
      content {
        from_port = port.value
        to_port = port.value
        protocol = "tcp"
        cidr_blocks = [var.vpc.cidr_block]
      }
    }
}

resource "aws_security_group" "ecs_sec_group" {
  description = "control traffic from load balancer to ecs"

  vpc_id = var.vpc.id
  dynamic "ingress" {
    for_each = [80, 443]
    iterator = port
    content {
      from_port = port.value
      to_port = port.value
      protocol = "tcp"
      security_groups = [aws_security_group.alb_sec_group.id]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_acm_certificate" "cert" {
#   domain_name       = "marek.example.com"
#   validation_method = "DNS"
#
#   tags = {
#     Environment = "dev"
#     User = "Marek"
#   }
#
#   lifecycle {
#     create_before_destroy = true
#   }
# }
