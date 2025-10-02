# Configuration Module Variables

# Basic Configuration
variable "service_name" {
  description = "Name of the service"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to resources"
  type        = map(string)
  default     = {}
}

# SSM Parameters
variable "parameters" {
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

# IAM Configuration
variable "create_iam_policy" {
  description = "Create IAM policy for SSM access"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string
  default     = null
}

