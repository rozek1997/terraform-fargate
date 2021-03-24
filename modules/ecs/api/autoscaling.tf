resource "aws_appautoscaling_target" "api" {
  service_namespace  = "ecs"
  resource_id        = join("/", ["service", var.module_setup.cluster.name, aws_ecs_service.api-service.name])
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.asg_min[terraform.workspace]
  max_capacity       = var.asg_max[terraform.workspace]
}

resource "aws_appautoscaling_policy" "api_up" {
  name               = join("-", [terraform.workspace, var.module_name, "scaleUp"])
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 2 //maybe 3 up if using smaller containers
    }
  }

  depends_on = [aws_appautoscaling_target.api]
}

resource "aws_appautoscaling_policy" "api_down" {
  name               = join("-", [terraform.workspace, var.module_name, "scaleDown"])
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.api.resource_id
  scalable_dimension = aws_appautoscaling_target.api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.api.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 300
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.api, aws_appautoscaling_policy.api_up]
}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = join("-", [terraform.workspace, var.module_name, "CPUUtilizationHigh"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "40"

  dimensions = {
    ClusterName = var.module_setup.cluster.name
    ServiceName = aws_ecs_service.api-service.name
  }

  alarm_actions = [aws_appautoscaling_policy.api_up.arn]
}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = join("-", [terraform.workspace, var.module_name, "CPUUtilizationLow"])
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    ClusterName = var.module_setup.cluster.name
    ServiceName = aws_ecs_service.api-service.name
  }
  alarm_actions = [aws_appautoscaling_policy.api_down.arn]
}
