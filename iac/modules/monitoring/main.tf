# Monitoring Module - CloudWatch alarms and dashboards
# This module creates monitoring and alerting for Lambda functions

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Local values
locals {
  common_tags = merge(var.tags, {
    Module = "monitoring"
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "${var.function_name}-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.error_evaluation_periods
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = var.error_period
  statistic           = "Sum"
  threshold           = var.error_threshold
  alarm_description   = "This metric monitors lambda errors"
  
  dimensions = {
    FunctionName = var.function_name
  }
  
  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  
  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_duration" {
  alarm_name          = "${var.function_name}-duration"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.duration_evaluation_periods
  metric_name         = "Duration"
  namespace           = "AWS/Lambda"
  period              = var.duration_period
  statistic           = "Average"
  threshold           = var.duration_threshold
  alarm_description   = "This metric monitors lambda duration"
  
  dimensions = {
    FunctionName = var.function_name
  }
  
  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  
  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_throttles" {
  count = var.enable_throttle_alarm ? 1 : 0
  
  alarm_name          = "${var.function_name}-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.throttle_evaluation_periods
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = var.throttle_period
  statistic           = "Sum"
  threshold           = var.throttle_threshold
  alarm_description   = "This metric monitors lambda throttles"
  
  dimensions = {
    FunctionName = var.function_name
  }
  
  alarm_actions = var.alarm_actions
  ok_actions    = var.ok_actions
  
  tags = local.common_tags
}

# Custom metric for business logic
resource "aws_cloudwatch_log_metric_filter" "custom_metrics" {
  for_each = var.custom_metrics
  
  name           = "${var.function_name}-${each.key}"
  log_group_name = var.log_group_name
  pattern        = each.value.filter_pattern
  
  metric_transformation {
    name      = each.value.metric_name
    namespace = each.value.namespace
    value     = each.value.value
  }
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "main" {
  count = var.enable_dashboard ? 1 : 0
  
  dashboard_name = "${var.function_name}-dashboard"
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "Invocations", "FunctionName", var.function_name],
            [".", "Errors", ".", "."],
            [".", "Duration", ".", "."],
            [".", "Throttles", ".", "."]
          ]
          period = 300
          stat   = "Sum"
          region = data.aws_region.current.name
          title  = "Lambda Metrics"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/Lambda", "ConcurrentExecutions", "FunctionName", var.function_name]
          ]
          period = 300
          stat   = "Average"
          region = data.aws_region.current.name
          title  = "Concurrent Executions"
        }
      }
    ]
  })
}

# Data sources
data "aws_region" "current" {}

