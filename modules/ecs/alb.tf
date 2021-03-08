resource "aws_alb" "main"{
  name = "marek-load-balancer"
  internal = false
  security_groups = [aws_security_group.alb_sec_group.id]
  subnets = var.vpc_public_subnets_ids
}

resource "aws_alb_target_group" "fargate_target_group" {
  name = "alb-target-group"
  port = 80
  protocol = "HTTP"
  vpc_id = var.vpc.id
  target_type = "ip"

  health_check {
    healthy_threshold = "3"
    unhealthy_threshold = "3"
    matcher = "200"
    timeout = 3
    path = "/"
    interval = "30"
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.fargate_target_group.arn
    type = "forward"
  }
}

# resource "aws_alb_listener" "front_ssl_end" {
#   load_balancer_arn = aws_alb.main.arn
#   port = 443
#   protocol = "HTTPS"
#   ssl_policy = "ELBSecurityPolicy-2016-08"
#   certificate_arn = aws_acm_certificate.cert.arn
#
#   default_action {
#     target_group_arn = aws_alb_target_group.fargate_target_group.arn
#     type = "forward"
#   }
# }
