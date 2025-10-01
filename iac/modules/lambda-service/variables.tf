# Lambda Service Module Variables

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
  default     = "hello_app.lambda_handler"
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

# Security Configuration
variable "enable_encryption" {
  description = "Enable KMS encryption"
  type        = bool
  default     = true
}

variable "tracing_mode" {
  description = "X-Ray tracing mode"
  type        = string
  default     = "PassThrough"
}

variable "additional_iam_statements" {
  description = "Additional IAM statements for the Lambda execution role"
  type        = list(any)
  default     = []
}

# Configuration Management
variable "ssm_parameters" {
  description = "SSM parameters to create"
  type = map(object({
    name        = string
    type        = string
    value       = string
    description = string
    tags        = map(string)
  }))
  default = {}
}

# Monitoring Configuration
variable "error_threshold" {
  description = "Error threshold for CloudWatch alarm"
  type        = number
  default     = 5
}

variable "alarm_actions" {
  description = "List of ARNs for alarm actions (SNS topics, etc.)"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs for OK actions"
  type        = list(string)
  default     = []
}

variable "custom_metrics" {
  description = "Custom metrics to create from log filters"
  type = map(object({
    filter_pattern = string
    metric_name   = string
    namespace     = string
    value         = string
  }))
  default = {}
}

variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = true
}

# Provisioned Concurrency Configuration
variable "enable_provisioned_concurrency" {
  description = "Enable provisioned concurrency"
  type        = bool
  default     = false
}

variable "provisioned_concurrency_count" {
  description = "Number of provisioned concurrent executions"
  type        = number
  default     = 1
}

# Auto Scaling Configuration
variable "enable_auto_scaling" {
  description = "Enable auto scaling for provisioned concurrency"
  type        = bool
  default     = false
}

variable "min_provisioned_concurrency" {
  description = "Minimum provisioned concurrency"
  type        = number
  default     = 1
}

variable "max_provisioned_concurrency" {
  description = "Maximum provisioned concurrency"
  type        = number
  default     = 10
}

variable "target_utilization" {
  description = "Target utilization for auto scaling (0.0 to 1.0)"
  type        = number
  default     = 0.7
}

variable "scale_out_cooldown" {
  description = "Scale out cooldown in seconds"
  type        = number
  default     = 300
}

variable "scale_in_cooldown" {
  description = "Scale in cooldown in seconds"
  type        = number
  default     = 300
}
