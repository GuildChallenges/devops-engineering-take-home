# Lambda Module - Reusable Lambda function with API Gateway
# This module creates a Lambda function with optional API Gateway integration

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
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}"
  common_tags = merge(var.tags, {
    Module = "lambda"
  })
}

# KMS key for encryption
resource "aws_kms_key" "lambda_key" {
  count = var.enable_encryption ? 1 : 0
  
  description             = "KMS key for ${local.name_prefix} Lambda function"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-kms-key"
  })
}

resource "aws_kms_alias" "lambda_key_alias" {
  count = var.enable_encryption ? 1 : 0
  
  name          = "alias/${local.name_prefix}-key"
  target_key_id = aws_kms_key.lambda_key[0].key_id
}

# IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "${local.name_prefix}-execution-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
  
  tags = local.common_tags
}

# IAM policy for Lambda execution
resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "${local.name_prefix}-execution-policy"
  description = "Policy for ${local.name_prefix} Lambda function"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
      }
    ], var.additional_iam_statements)
  })
  
  tags = local.common_tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attachment" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

# Attach basic execution role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${local.name_prefix}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.enable_encryption ? aws_kms_key.lambda_key[0].arn : null
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-logs"
  })
}

# Lambda function
resource "aws_lambda_function" "main" {
  filename         = var.lambda_package_path
  function_name    = local.name_prefix
  role            = aws_iam_role.lambda_execution_role.arn
  handler         = var.lambda_handler
  runtime         = var.lambda_runtime
  timeout         = var.lambda_timeout
  memory_size     = var.lambda_memory_size
  
  # Environment variables
  environment {
    variables = var.environment_variables
  }
  
  # VPC configuration (optional)
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }
  
  # Dead letter queue configuration
  dynamic "dead_letter_config" {
    for_each = var.dead_letter_queue_arn != null ? [1] : []
    content {
      target_arn = var.dead_letter_queue_arn
    }
  }
  
  # Tracing configuration
  tracing_config {
    mode = var.tracing_mode
  }
  
  # File system configuration (if needed)
  dynamic "file_system_config" {
    for_each = var.file_system_config != null ? [var.file_system_config] : []
    content {
      arn              = file_system_config.value.arn
      local_mount_path = file_system_config.value.local_mount_path
    }
  }
  
  depends_on = [
    aws_cloudwatch_log_group.lambda_logs,
    aws_iam_role_policy_attachment.lambda_execution_policy_attachment
  ]
  
  tags = local.common_tags
}

# API Gateway (if enabled)
resource "aws_api_gateway_rest_api" "main" {
  count = var.enable_api_gateway ? 1 : 0
  
  name        = "${local.name_prefix}-api"
  description = "API Gateway for ${local.name_prefix}"
  
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  
  tags = local.common_tags
}

# API Gateway resource
resource "aws_api_gateway_resource" "main" {
  count = var.enable_api_gateway ? 1 : 0
  
  rest_api_id = aws_api_gateway_rest_api.main[0].id
  parent_id   = aws_api_gateway_rest_api.main[0].root_resource_id
  path_part   = var.api_path
}

# API Gateway method
resource "aws_api_gateway_method" "main" {
  count = var.enable_api_gateway ? 1 : 0
  
  rest_api_id   = aws_api_gateway_rest_api.main[0].id
  resource_id   = aws_api_gateway_resource.main[0].id
  http_method   = var.api_method
  authorization = var.api_authorization
}

# API Gateway Lambda integration
resource "aws_api_gateway_integration" "lambda_integration" {
  count = var.enable_api_gateway ? 1 : 0
  
  rest_api_id = aws_api_gateway_rest_api.main[0].id
  resource_id = aws_api_gateway_resource.main[0].id
  http_method = aws_api_gateway_method.main[0].http_method
  
  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.main.invoke_arn
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "main" {
  count = var.enable_api_gateway ? 1 : 0
  
  rest_api_id = aws_api_gateway_rest_api.main[0].id
  stage_name  = var.environment
  
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
  
  lifecycle {
    create_before_destroy = true
  }
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  count = var.enable_api_gateway ? 1 : 0
  
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main[0].execution_arn}/*/*"
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

