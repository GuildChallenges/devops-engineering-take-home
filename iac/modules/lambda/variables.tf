# Lambda Module Variables

# Basic Configuration
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Lambda Configuration
variable "lambda_package_path" {
  description = "Path to the Lambda deployment package"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda function handler"
  type        = string
}

variable "lambda_runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.11"
}

variable "lambda_timeout" {
  description = "Lambda function timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Lambda function memory size in MB"
  type        = number
  default     = 256
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default     = {}
}

# Logging Configuration
variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

# API Gateway Configuration
variable "enable_api_gateway" {
  description = "Enable API Gateway integration"
  type        = bool
  default     = true
}

variable "api_path" {
  description = "API Gateway path"
  type        = string
  default     = "hello"
}

variable "api_method" {
  description = "API Gateway HTTP method"
  type        = string
  default     = "POST"
}

variable "api_authorization" {
  description = "API Gateway authorization"
  type        = string
  default     = "NONE"
}

# VPC Configuration
variable "vpc_config" {
  description = "VPC configuration for Lambda function"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  default = null
}

# File System Configuration
variable "file_system_config" {
  description = "File system configuration for Lambda function"
  type = object({
    arn              = string
    local_mount_path = string
  })
  default = null
}

# Security Configuration
variable "enable_encryption" {
  description = "Enable KMS encryption"
  type        = bool
  default     = true
}

variable "dead_letter_queue_arn" {
  description = "ARN of the dead letter queue"
  type        = string
  default     = null
}

variable "tracing_mode" {
  description = "X-Ray tracing mode"
  type        = string
  default     = "PassThrough"
}

# IAM Configuration
variable "additional_iam_statements" {
  description = "Additional IAM statements for the Lambda execution role"
  type        = list(any)
  default     = []
}

