# Monitoring Module Outputs

# CloudWatch Alarms
output "error_alarm_name" {
  description = "Name of the error alarm"
  value       = aws_cloudwatch_metric_alarm.lambda_errors.alarm_name
}

output "duration_alarm_name" {
  description = "Name of the duration alarm"
  value       = aws_cloudwatch_metric_alarm.lambda_duration.alarm_name
}

output "throttle_alarm_name" {
  description = "Name of the throttle alarm"
  value       = var.enable_throttle_alarm ? aws_cloudwatch_metric_alarm.lambda_throttles[0].alarm_name : null
}

# Dashboard
output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = var.enable_dashboard ? "https://${data.aws_region.current.name}.console.aws.amazon.com/cloudwatch/home?region=${data.aws_region.current.name}#dashboards:name=${aws_cloudwatch_dashboard.main[0].dashboard_name}" : null
}

# Custom Metrics
output "custom_metric_names" {
  description = "Names of custom metrics created"
  value       = [for k, v in aws_cloudwatch_log_metric_filter.custom_metrics : v.metric_transformation[0].name]
}

