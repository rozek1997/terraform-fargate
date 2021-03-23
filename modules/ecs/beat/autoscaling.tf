resource "aws_appautoscaling_target" "beat" {
  service_namespace  = "ecs"
  resource_id        = join("/", ["service", var.module_setup.cluster.name, aws_ecs_service.beat_service.name])
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.asg_min[terraform.workspace]
  max_capacity       = var.asg_max[terraform.workspace]
}

//resource "aws_appautoscaling_policy" "beat_up" {
//  name               = "scale-up"
//  policy_type        = "StepScaling"
//  resource_id        = aws_appautoscaling_target.beat.resource_id
//  scalable_dimension = aws_appautoscaling_target.beat.scalable_dimension
//  service_namespace  = aws_appautoscaling_target.beat.service_namespace
//
//  step_scaling_policy_configuration {
//    adjustment_type         = "ChangeInCapacity"
//    cooldown                = 360
//    metric_aggregation_type = "Maximum"
//
//    step_adjustment {
//      metric_interval_lower_bound = 0
//      scaling_adjustment          = 1
//    }
//  }
//
//}
//
//# Remove one task
//resource "aws_appautoscaling_policy" "beat_down" {
//  name               = "scale-up"
//  policy_type        = "StepScaling"
//  resource_id        = aws_appautoscaling_target.beat.resource_id
//  scalable_dimension = aws_appautoscaling_target.beat.scalable_dimension
//  service_namespace  = aws_appautoscaling_target.beat.service_namespace
//
//  step_scaling_policy_configuration {
//    adjustment_type         = "ChangeInCapacity"
//    cooldown                = 300
//    metric_aggregation_type = "Maximum"
//
//    step_adjustment {
//      metric_interval_lower_bound = 0
//      scaling_adjustment          = -1
//    }
//  }
//}

# CloudWatch alarm that triggers the autoscaling up policy
resource "aws_cloudwatch_metric_alarm" "beat_service_cpu_high" {
  alarm_name          = join("-", [terraform.workspace, var.module_name, "CPUUtilizationHigh"])
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    ClusterName = var.module_setup.cluster.name
    ServiceName = aws_ecs_service.beat_service.name
  }

}

# CloudWatch alarm that triggers the autoscaling down policy
resource "aws_cloudwatch_metric_alarm" "beat_service_cpu_low" {
  alarm_name          = join("-", [terraform.workspace, var.module_name, "CPUUtilizationLow"])
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "120"

  dimensions = {
    ClusterName = var.module_setup.cluster.name
    ServiceName = aws_ecs_service.beat_service.name
  }
}
