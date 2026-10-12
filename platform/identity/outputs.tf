output "group_object_ids" {
  description = "Microsoft Entra object IDs keyed by group purpose."
  value       = { for key, group in azuread_group.platform : key => group.object_id }
}

output "role_assignment_ids" {
  description = "Azure role-assignment resource IDs keyed by group purpose."
  value       = { for key, assignment in azurerm_role_assignment.platform : key => assignment.id }
}

output "platform_automation_client_ids" {
  description = "Non-secret client IDs used as GitHub repository environment variables."
  value       = { for key, application in azuread_application.platform_automation : key => application.client_id }
}

output "platform_automation_federated_subjects" {
  description = "GitHub OIDC subjects trusted by the platform automation identities."
  value       = { for key, credential in azuread_application_federated_identity_credential.platform_automation : key => credential.subject }
}
