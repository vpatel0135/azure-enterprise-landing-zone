output "name" {
  description = "Generated Azure resource name."
  value       = var.use_hyphens ? join("-", local.components) : join("", local.components)
}

output "components" {
  description = "Normalized components used to generate the name."
  value = {
    resource_type      = var.resource_type
    region_environment = local.region_environment
    workload_code      = var.workload_code
    instance           = var.instance
  }
}
