output "resource_group_name" {
  description = "Resource group containing the Terraform state backend."
  value       = azurerm_resource_group.state.name
}

output "storage_account_name" {
  description = "Storage account containing Terraform state containers."
  value       = azurerm_storage_account.state.name
}

output "container_names" {
  description = "Platform state containers created by the bootstrap."
  value       = sort(keys(azurerm_storage_container.state))
}

output "backend_configuration" {
  description = "Non-secret values needed to migrate this root to its remote backend."
  value = {
    resource_group_name  = azurerm_resource_group.state.name
    storage_account_name = azurerm_storage_account.state.name
    container_name       = azurerm_storage_container.state["bootstrap"].name
    key                  = "bootstrap.tfstate"
    use_azuread_auth     = true
  }
}
