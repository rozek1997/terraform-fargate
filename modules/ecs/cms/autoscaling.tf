resource "aws_appautoscaling_target" "cms" {
  service_namespace  = "ecs"
  resource_id        = join("/", ["service", var.module_setup.cluster.name, aws_ecs_service.cms_service.name])
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.asg_min[terraform.workspace]
  max_capacity       = var.asg_max[terraform.workspace]
}

resource "aws_appautoscaling_policy" "cms_up" {
  name               = join("-", [terraform.workspace, var.module_name, "scaleUp"])
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.cms.resource_id
  scalable_dimension = aws_appautoscaling_target.cms.scalable_dimension
  service_namespace  = aws_appautoscaling_target.cms.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 2
    }
  }

  depends_on = [aws_appautoscaling_target.cms]

}

# Remove one task
resource "aws_appautoscaling_policy" "cms_down" {
  name               = join("-", [terraform.workspace, var.module_name, "scaleDown"])
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.cms.resource_id
  scalable_dimension = aws_appautoscaling_target.cms.scalable_dimension
  service_namespace  = aws_appautoscaling_target.cms.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.cms, aws_appautoscaling_policy.cms_up]
}

// !!! currently cms are using networks out based scaling by it is not available out of the box in AWS/ECS namespace
// so I'm using CPUUtilization instead, treshold set as on API autoscaling
resource "aws_cloudwatch_metric_alarm" "cms_service_cpu_high" {
  alarm_name          = join("-", [terraform.workspace, var.module_name, "CPUUtilizationHigh"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "NetworksOut"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = var.module_setup.cluster.name
    ServiceName = aws_ecs_service.cms_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.cms_up.arn]
}

// !!! currently cms are using networks out based scaling by it is not available out of the box in AWS/ECS namespace
// so I'm using CPUUtilization instead, treshold set as on API autoscaling
resource "aws_cloudwatch_metric_alarm" "cms_service_cpu_low" {
  alarm_name          = join("-", [terraform.workspace, var.module_name, "CPUUtilizationLow"])
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    ClusterName = var.module_setup.cluster.name
    ServiceName = aws_ecs_service.cms_service.name
  }
  alarm_actions = [aws_appautoscaling_policy.cms_down.arn]
}