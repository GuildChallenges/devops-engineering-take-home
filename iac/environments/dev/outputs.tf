# Development Environment Outputs

# Lambda Function
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_service.lambda_function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_service.lambda_function_arn
}

# API Gateway
output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = module.lambda_service.api_gateway_url
}

# CloudWatch
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.lambda_service.log_group_name
}

# Monitoring
output "dashboard_url" {
  description = "URL of the CloudWatch dashboard"
  value       = module.lambda_service.dashboard_url
}

# Service Information
output "service_info" {
  description = "Service information"
  value       = module.lambda_service.service_info
}
