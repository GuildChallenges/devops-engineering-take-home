# Local values for Lambda Module

locals {
  name_prefix = "${var.project_name}-${var.environment}-${var.service_name}"
  common_tags = merge(var.tags, {
    Module = "lambda"
  })
}
