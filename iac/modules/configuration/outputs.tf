# Configuration Module Outputs

# SSM Parameters
output "parameter_names" {
  description = "Names of the SSM parameters"
  value       = { for k, v in aws_ssm_parameter.parameters : k => v.name }
}

output "parameter_arns" {
  description = "ARNs of the SSM parameters"
  value       = { for k, v in aws_ssm_parameter.parameters : k => v.arn }
}

# IAM Policy
output "ssm_access_policy_arn" {
  description = "ARN of the SSM access policy"
  value       = var.create_iam_policy ? aws_iam_policy.ssm_access_policy[0].arn : null
}

