# Lambda Module Outputs

# Lambda Function
output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.main.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.main.arn
}

output "lambda_function_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.main.invoke_arn
}

# API Gateway
output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = var.enable_api_gateway ? "https://${aws_api_gateway_rest_api.main[0].id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.environment}" : null
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = var.enable_api_gateway ? aws_api_gateway_rest_api.main[0].id : null
}

# CloudWatch
output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = aws_cloudwatch_log_group.lambda_logs.arn
}

# IAM
output "lambda_execution_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_execution_role.arn
}

# KMS
output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = var.enable_encryption ? aws_kms_key.lambda_key[0].arn : null
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = var.enable_encryption ? aws_kms_key.lambda_key[0].key_id : null
}

