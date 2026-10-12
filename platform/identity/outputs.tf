output "group_object_ids" {
  description = "Microsoft Entra object IDs keyed by group purpose."
  value       = { for key, group in azuread_group.platform : key => group.object_id }
}

output "role_assignment_ids" {
  description = "Azure role-assignment resource IDs keyed by group purpose."
  value       = { for key, assignment in azurerm_role_assignment.platform : key => assignment.id }
}
