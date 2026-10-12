output "resource_groups" {
  description = "Governed environment resource groups keyed by lifecycle."
  value = {
    for key, resource_group in azurerm_resource_group.environment : key => {
      id       = resource_group.id
      name     = resource_group.name
      location = resource_group.location
    }
  }
}

output "operator_role_assignment_ids" {
  description = "Contributor role assignments keyed by lifecycle."
  value       = { for key, assignment in azurerm_role_assignment.operator : key => assignment.id }
}
