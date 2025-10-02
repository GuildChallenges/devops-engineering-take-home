# Configuration Module - SSM Parameter Store management
# This module manages configuration parameters for the service

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
  common_tags = merge(var.tags, {
    Module = "configuration"
  })
}

# SSM Parameters
resource "aws_ssm_parameter" "parameters" {
  for_each = var.parameters
  
  name  = each.value.name
  type  = each.value.type
  value = each.value.value
  
  description = each.value.description
  
  # Allow overwriting existing parameters
  overwrite = true
  
  lifecycle {
    ignore_changes = [name]
  }
  
  tags = merge(local.common_tags, each.value.tags)
}

# SSM Parameter Store access policy
resource "aws_iam_policy" "ssm_access_policy" {
  count = var.create_iam_policy ? 1 : 0
  
  name        = "${var.service_name}-ssm-access-policy"
  description = "Policy for accessing SSM parameters for ${var.service_name}"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          for param in var.parameters : "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${param.name}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arn != null ? [var.kms_key_arn] : []
      }
    ]
  })
  
  tags = local.common_tags
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

