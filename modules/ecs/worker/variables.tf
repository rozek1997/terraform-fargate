#alb
variable "module_name" {
  default = "worker"
}

variable "module_setup" {}

#cloudwatch
variable "app_log_group" {}
variable "app_log_stream" {}

# Scaling
variable "asg_max" {
  description = "Max containers in autoscaling group"
  default = {
    dev     = 2
    staging = 2
    prod    = 20
  }
}

variable "asg_min" {
  description = "Minimum instances in Auto scaling group"
  default = {
    dev     = 1
    staging = 1
    prod    = 5
  }
}


variable "fargate_cpu" {
  description = "Describe CPU values for Fargate launch type"
  default = {
    dev     = 1024
    staging = 1024
    prod    = 2048
  }
}

variable "fargate_memory" {
  description = "Describe memory values for Fargate launch type"
  default = {
    dev     = 2048
    staging = 2048
    prod    = 4096
  }
}

variable "application_memory_reservation" {
  default = {
    dev     = 350
    staging = 350
    prod    = 600
  }
}


locals {
  dynamic_env_vars = {
    CHAT_INACTIVE_DELAY_SECONDS = {
      dev     = 60
      staging = null
      prod    = null
    }
    UWSGI_MAX_REQUESTS = {
      dev     = null
      staging = null
      prod    = null
    }
    UWSGI_THREADS = {
      dev     = null
      staging = null
      prod    = null
    }
    WEB_CONCURRENCY = {
      dev     = 3
      staging = 3
      prod    = 5
    }
    WHITE_LABEL_CNAME = {
      dev     = "front-dev.netlify.com"
      staging = "custom-domains.crowdcomms.com"
      prod    = "prod-custom-domains-alb-74253846.eu-central-1.elb.amazonaws.com"
    }
  }

}



