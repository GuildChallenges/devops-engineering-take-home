# Lambda Service Module - Main Configuration
# This is the main module that can be called from different environments

# Random ID for unique resource names
resource "random_id" "service_suffix" {
  byte_length = 4
}

# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  name                      = "${local.name_prefix}-dlq-${random_id.service_suffix.hex}"
  message_retention_seconds = 1209600 # 14 days
  kms_master_key_id         = var.enable_encryption ? aws_kms_key.dlq_key[0].arn : null
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-dlq"
  })
  
  lifecycle {
    ignore_changes = [name, kms_master_key_id]
  }
}

# KMS key for DLQ encryption
resource "aws_kms_key" "dlq_key" {
  count = var.enable_encryption ? 1 : 0
  
  description             = "KMS key for ${local.name_prefix} DLQ"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-dlq-key"
  })
}

# Lambda Module
module "lambda" {
  source = "../lambda"
  
  # Basic Configuration
  project_name = var.project_name
  environment  = var.environment
  service_name = var.service_name
  tags         = local.common_tags
  
  # Lambda Configuration
  lambda_package_path = var.lambda_package_path
  lambda_handler      = var.lambda_handler
  lambda_runtime      = var.lambda_runtime
  lambda_timeout      = var.lambda_timeout
  lambda_memory_size  = var.lambda_memory_size
  
  # Environment Variables
  environment_variables = var.environment_variables
  
  # Logging Configuration
  log_retention_days = var.log_retention_days
  
  # API Gateway Configuration
  enable_api_gateway = var.enable_api_gateway
  api_path          = var.api_path
  api_method        = var.api_method
  api_authorization  = var.api_authorization
  
  # Security Configuration
  enable_encryption      = var.enable_encryption
  dead_letter_queue_arn = aws_sqs_queue.dlq.arn
  tracing_mode          = var.tracing_mode
  
  # Additional IAM statements for SSM access
  additional_iam_statements = concat([
    {
      Effect = "Allow"
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ]
      Resource = [
        "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/guild/${var.service_name}/*"
      ]
    },
    {
      Effect = "Allow"
      Action = [
        "kms:Decrypt"
      ]
      Resource = var.enable_encryption ? [aws_kms_key.dlq_key[0].arn] : []
    }
  ], var.additional_iam_statements)
}

# Configuration Module
module "configuration" {
  source = "../configuration"
  
  service_name = var.service_name
  tags        = local.common_tags
  
  parameters = var.ssm_parameters
  
  create_iam_policy = false  # We handle IAM in the lambda module
  kms_key_arn       = var.enable_encryption ? aws_kms_key.dlq_key[0].arn : null
}

# Monitoring Module
module "monitoring" {
  source = "../monitoring"
  
  function_name   = module.lambda.lambda_function_name
  log_group_name  = module.lambda.log_group_name
  tags           = local.common_tags
  
  # Alarm Configuration
  error_threshold    = var.error_threshold
  duration_threshold = var.lambda_timeout * 1000 * 0.8  # 80% of timeout
  alarm_actions      = var.alarm_actions
  ok_actions         = var.ok_actions
  
  # Custom Metrics
  custom_metrics = var.custom_metrics
  
  # Dashboard
  enable_dashboard = var.enable_dashboard
}

# Provisioned Concurrency (optional)
resource "aws_lambda_provisioned_concurrency_config" "main" {
  count = var.enable_provisioned_concurrency ? 1 : 0
  
  function_name                     = module.lambda.lambda_function_name
  qualifier                        = module.lambda.lambda_function_version
  provisioned_concurrent_executions = var.provisioned_concurrency_count
}

# Application Auto Scaling for Provisioned Concurrency (optional)
resource "aws_appautoscaling_target" "lambda_target" {
  count = var.enable_auto_scaling ? 1 : 0
  
  max_capacity       = var.max_provisioned_concurrency
  min_capacity       = var.min_provisioned_concurrency
  resource_id        = "function:${module.lambda.lambda_function_name}:${module.lambda.lambda_function_version}"
  scalable_dimension = "lambda:function:provisioned-concurrency"
  service_namespace  = "lambda"
}

resource "aws_appautoscaling_policy" "lambda_scaling_policy" {
  count = var.enable_auto_scaling ? 1 : 0
  
  name               = "${local.name_prefix}-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.lambda_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.lambda_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.lambda_target[0].service_namespace
  
  target_tracking_scaling_policy_configuration {
    target_value = var.target_utilization
    
    predefined_metric_specification {
      predefined_metric_type = "LambdaProvisionedConcurrencyUtilization"
    }
    
    scale_out_cooldown = var.scale_out_cooldown
    scale_in_cooldown  = var.scale_in_cooldown
  }
}
