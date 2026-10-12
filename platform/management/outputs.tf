output "resource_group_name" {
  description = "Management resource-group name."
  value       = azurerm_resource_group.management.name
}

output "log_analytics_workspace_id" {
  description = "Central platform Log Analytics workspace resource ID."
  value       = azurerm_log_analytics_workspace.platform.id
}

output "enabled_activity_log_categories" {
  description = "Subscription Activity Log categories sent to the platform workspace."
  value       = sort(tolist(local.activity_log_categories))
}
