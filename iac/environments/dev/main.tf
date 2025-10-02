# Development Environment Configuration
# This file calls the lambda-service module with development-specific values

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
  
  default_tags {
    tags = {
      Project     = "guild"
      Environment = "dev"
      Service     = "hello-service"
      ManagedBy   = "terraform"
      Owner       = "devops-team"
    }
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Local values
locals {
  common_tags = {
    Project     = "guild"
    Environment = "dev"
    Service     = "hello-service"
    ManagedBy   = "terraform"
    Owner       = "devops-team"
  }
}

# Call the Lambda Service Module
module "lambda_service" {
  source = "../../modules/lambda-service"
  
  # Basic Configuration
  project_name = "guild"
  environment  = "dev"
  service_name = "hello-service"
  tags         = local.common_tags
  
  # Lambda Configuration
  lambda_package_path = "../../dist/lambda.zip"
  lambda_handler      = "hello_app.lambda_handler"
  lambda_runtime      = "python3.11"
  lambda_timeout      = 30
  lambda_memory_size  = 256
  
  # Environment Variables
  environment_variables = {
    ENVIRONMENT      = "dev"
    SERVICE_VERSION  = "1.0.0"
    LOG_LEVEL        = "DEBUG"
    GREETING_MESSAGE = "Hello from Guild!"
  }
  
  # Logging Configuration
  log_retention_days = 7  # Shorter retention for cost savings
  
  # API Gateway Configuration
  enable_api_gateway = true
  api_path          = "hello"
  api_method        = "POST"
  api_authorization  = "NONE"
  
  # Security Configuration
  enable_encryption = true
  tracing_mode      = "PassThrough"
  
  # SSM Parameters
  ssm_parameters = {
    greeting_message = {
      name        = "/guild/hello-service/message"
      type        = "String"
      value       = "Hello from Development!"
      description = "Greeting message for development environment"
      tags        = local.common_tags
    }
  }
  
  # Monitoring Configuration
  error_threshold = 5
  alarm_actions   = []
  ok_actions      = []
  enable_dashboard = true
  
  # Custom Metrics
  custom_metrics = {}
  
  # Provisioned Concurrency (disabled for dev)
  enable_provisioned_concurrency = false
  provisioned_concurrency_count  = 1
  
  # Auto Scaling (disabled for dev)
  enable_auto_scaling           = false
  min_provisioned_concurrency   = 1
  max_provisioned_concurrency   = 10
  target_utilization           = 0.7
  scale_out_cooldown           = 300
  scale_in_cooldown            = 300
}
