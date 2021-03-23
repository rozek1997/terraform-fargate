variable "public_subnets_ids" {}

variable "vpc_id" {}

//variable "loadbalancer_certificate_arn" {}

variable "open_ports" {
  type = map(number)
  default = {
    HTTP  = 80
    HTTPS = 443
    UWSGI_PORT = 8080
  }
}

variable "alb_security_policy" {
  default = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

variable "health_check" {
  type = map
  default = {
    path                = "/"
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 10
  }
}

variable "cms-host-header" {
  type    = string
  default = "*api-cms.example.com"
}

variable "api-host-header" {
  type    = string
  default = "*api.example.com"
}

