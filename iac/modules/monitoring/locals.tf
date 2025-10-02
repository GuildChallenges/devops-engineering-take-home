# Local values for Monitoring Module

locals {
  common_tags = merge(var.tags, {
    Module = "monitoring"
  })
}
