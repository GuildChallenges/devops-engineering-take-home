# Lambda Service Module Outputs

# Lambda Function (from module)
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.lambda_function_arn
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = module.lambda.lambda_function_invoke_arn
}

# API Gateway (from module)
output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.lambda.api_gateway_url
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = module.lambda.api_gateway_id
}

# CloudWatch (from module)
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.lambda.log_group_name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = module.lambda.log_group_arn
}

# IAM (from module)
output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = module.lambda.lambda_execution_role_arn
}

# SSM Parameters (from module)
output "ssm_parameter_names" {
  description = "Names of the SSM parameters"
  value       = module.configuration.parameter_names
}

output "ssm_parameter_arns" {
  description = "ARNs of the SSM parameters"
  value       = module.configuration.parameter_arns
}

# Monitoring (from module)
output "cloudwatch_alarms" {
  description = "CloudWatch alarm names"
  value = {
    errors    = module.monitoring.error_alarm_name
    duration  = module.monitoring.duration_alarm_name
    throttles = module.monitoring.throttle_alarm_name
  }
}

output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = module.monitoring.dashboard_url
}

# Dead Letter Queue
output "dlq_arn" {
  description = "ARN of the dead letter queue"
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_url" {
  description = "URL of the dead letter queue"
  value       = aws_sqs_queue.dlq.url
}

# KMS (from module)
output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = module.lambda.kms_key_arn
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = module.lambda.kms_key_id
}

# Provisioned Concurrency
output "provisioned_concurrency_config" {
  description = "Provisioned concurrency configuration"
  value = var.enable_provisioned_concurrency ? {
    function_name = aws_lambda_provisioned_concurrency_config.main[0].function_name
    provisioned_concurrency_config_name = aws_lambda_provisioned_concurrency_config.main[0].provisioned_concurrency_config_name
    provisioned_concurrency_count = aws_lambda_provisioned_concurrency_config.main[0].provisioned_concurrency_count
  } : null
}

# Auto Scaling
output "auto_scaling_target" {
  description = "Auto scaling target configuration"
  value = var.enable_auto_scaling ? {
    resource_id        = aws_appautoscaling_target.lambda_target[0].resource_id
    scalable_dimension = aws_appautoscaling_target.lambda_target[0].scalable_dimension
    service_namespace  = aws_appautoscaling_target.lambda_target[0].service_namespace
    min_capacity       = aws_appautoscaling_target.lambda_target[0].min_capacity
    max_capacity       = aws_appautoscaling_target.lambda_target[0].max_capacity
  } : null
}

# Service Information
output "service_info" {
  description = "Service information"
  value = {
    project_name    = var.project_name
    environment     = var.environment
    service_name    = var.service_name
    aws_region      = data.aws_region.current.name
    aws_account_id  = data.aws_caller_identity.current.account_id
  }
}
