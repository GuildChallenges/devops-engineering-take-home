# Monitoring Module Variables

# Basic Configuration
variable "function_name" {
  description = "Name of the Lambda function to monitor"
  type        = string
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Error Alarm Configuration
variable "error_threshold" {
  description = "Error threshold for alarm"
  type        = number
  default     = 5
}

variable "error_period" {
  description = "Period for error alarm in seconds"
  type        = number
  default     = 300
}

variable "error_evaluation_periods" {
  description = "Number of evaluation periods for error alarm"
  type        = number
  default     = 2
}

# Duration Alarm Configuration
variable "duration_threshold" {
  description = "Duration threshold in milliseconds"
  type        = number
  default     = 24000  # 24 seconds (80% of 30s timeout)
}

variable "duration_period" {
  description = "Period for duration alarm in seconds"
  type        = number
  default     = 300
}

variable "duration_evaluation_periods" {
  description = "Number of evaluation periods for duration alarm"
  type        = number
  default     = 2
}

# Throttle Alarm Configuration
variable "enable_throttle_alarm" {
  description = "Enable throttle alarm"
  type        = bool
  default     = true
}

variable "throttle_threshold" {
  description = "Throttle threshold"
  type        = number
  default     = 1
}

variable "throttle_period" {
  description = "Period for throttle alarm in seconds"
  type        = number
  default     = 300
}

variable "throttle_evaluation_periods" {
  description = "Number of evaluation periods for throttle alarm"
  type        = number
  default     = 1
}

# Alarm Actions
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

# Dashboard Configuration
variable "enable_dashboard" {
  description = "Enable CloudWatch dashboard"
  type        = bool
  default     = true
}

# Custom Metrics
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

