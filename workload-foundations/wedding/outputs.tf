output "operator_group_object_id" {
  description = "Microsoft Entra object ID of the Wedding operator group."
  value       = azuread_group.operators.object_id
}

output "resource_groups" {
  description = "Wedding environment resource groups keyed by lifecycle."
  value       = module.foundation.resource_groups
}
