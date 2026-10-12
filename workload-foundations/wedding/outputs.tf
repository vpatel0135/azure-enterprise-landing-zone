output "operator_group_object_id" {
  description = "Microsoft Entra object ID of the Wedding operator group."
  value       = azuread_group.operators.object_id
}

output "resource_groups" {
  description = "Wedding environment resource groups keyed by lifecycle."
  value       = module.foundation.resource_groups
}

output "automation_client_ids" {
  description = "Non-secret client IDs keyed by Wedding environment and plan/apply purpose."
  value       = { for key, application in azuread_application.automation : key => application.client_id }
}

output "automation_federated_subjects" {
  description = "GitHub OIDC subjects trusted by the Wedding automation identities."
  value       = { for key, credential in azuread_application_federated_identity_credential.automation : key => credential.subject }
}
