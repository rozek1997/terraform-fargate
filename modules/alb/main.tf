locals {
  tags = {
    Environment = terraform.workspace
  }
}


resource "aws_alb" "app" {
  name                             = "${terraform.workspace}-load-balancer"
  internal                         = false
  security_groups                  = [aws_security_group.alb.id]
  enable_cross_zone_load_balancing = true
  subnets                          = var.public_subnets_ids
  tags                             = local.tags

}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_alb.app.arn
  protocol          = "HTTP"
  port              = var.open_ports["HTTP"]

//  default_action {
//    type             = "redirect"
//
//    redirect {
//      port        =  var.open_ports["HTTPS"]
//      protocol    = "HTTPS"
//      status_code = "HTTP_301"
//    }
//  }

  default_action {
        target_group_arn = aws_alb_target_group.api.arn
        type             = "forward"
  }

}

//resource "aws_alb_listener" "https" {
//  load_balancer_arn = aws_alb.app.arn
//  protocol          = "HTTPS"
//  port              = var.open_ports["HTTPS"]
//  ssl_policy        = var.alb_security_policy
//  certificate_arn   = var.loadbalancer_certificate_arn
//
//  default_action {
//    target_group_arn = aws_alb_target_group.api.arn
//    type             = "forward"
//  }
//}

resource "aws_alb_listener_rule" "api-https-forwarding" {
  listener_arn = aws_alb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.api.arn
  }

  condition {
    host_header {
      values = [var.api-host-header]
    }
  }

}

resource "aws_alb_listener_rule" "cms-https-forwarding" {
  listener_arn = aws_alb_listener.http.arn

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.cms.arn
  }

  condition {
    host_header {
      values = [var.cms-host-header]
    }
  }
}

resource "aws_alb_target_group" "api" {

  name_prefix = "api-"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port = var.open_ports["UWSGI_PORT"]
  target_type = "ip"

  health_check {
    path                = var.health_check.path
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    timeout             = var.health_check.timeout
    interval            = var.health_check.interval
  }

  tags = local.tags
}

resource "aws_alb_target_group" "cms" {

  name_prefix = "cms-"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port = var.open_ports["UWSGI_PORT"]
  target_type = "ip"

  health_check {
    path                = var.health_check.path
    healthy_threshold   = var.health_check.healthy_threshold
    unhealthy_threshold = var.health_check.unhealthy_threshold
    timeout             = var.health_check.timeout
    interval            = var.health_check.interval
  }

  tags = local.tags
}