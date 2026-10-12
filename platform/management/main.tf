locals {
  resource_group_name = "rg-eus2p-mgmt-01"
  workspace_name      = "law-eus2p-mgmt-01"

  required_tags = {
    application         = "platform-management"
    environment         = "production"
    owner-group         = "sg-alz-platform-operators"
    cost-center         = "portfolio-demo"
    managed-by          = "terraform"
    criticality         = "high"
    data-classification = "internal"
  }

  activity_log_categories = toset([
    "Administrative",
    "Alert",
    "Policy",
    "Recommendation",
    "ResourceHealth",
    "Security",
    "ServiceHealth",
  ])
}

resource "azurerm_resource_group" "management" {
  name     = local.resource_group_name
  location = var.location
  tags     = merge(var.tags, local.required_tags)
}

resource "azurerm_log_analytics_workspace" "platform" {
  name                = local.workspace_name
  resource_group_name = azurerm_resource_group.management.name
  location            = azurerm_resource_group.management.location

  sku               = "PerGB2018"
  retention_in_days = 30
  daily_quota_gb    = var.daily_quota_gb

  local_authentication_enabled       = false
  internet_ingestion_enabled         = true
  internet_query_enabled             = true
  reservation_capacity_in_gb_per_day = null

  tags = merge(var.tags, local.required_tags)
}

resource "azurerm_monitor_diagnostic_setting" "subscription_activity" {
  name                       = "diag-subscription-activity-law"
  target_resource_id         = "/subscriptions/${var.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.platform.id

  dynamic "enabled_log" {
    for_each = local.activity_log_categories

    content {
      category = enabled_log.value
    }
  }
}
