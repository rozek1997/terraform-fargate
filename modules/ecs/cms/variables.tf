#alb
variable "alb_target_group" {}

#cloudwatch
variable "app_log_group" {}
variable "app_log_stream" {}

variable "module_name" {
  default = "cms"
}

variable "module_setup" {}
# Scaling
variable "asg_max" {
  description = "Max containers in autoscaling group"
  default = {
    dev     = 1
    staging = 4
    prod    = 10
  }
}

variable "asg_min" {
  description = "Minimum instances in Auto scaling group"
  default = {
    dev     = 1
    staging = 1
    prod     = 5
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
    prod    = 8192
  }
}

variable "application_memory_reservation" {
  default = {
    dev     = 600
    staging = 600
    prod    = 1200
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
      dev     = 100
      staging = 100
      prod    = 800
    }
    UWSGI_THREADS = {
      dev     = 2
      staging = 2
      prod    = 4
    }
    WEB_CONCURRENCY = {
      dev     = 2
      staging = 2
      prod    = 6
    }
    WHITE_LABEL_CNAME = {
      dev     = "front-dev.netlify.com"
      staging = "custom-domains.crowdcomms.com"
      prod    = null
    }
  }

}



