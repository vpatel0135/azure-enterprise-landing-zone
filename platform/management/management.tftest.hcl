mock_provider "azurerm" {}

variables {
  tenant_id       = "00000000-0000-0000-0000-000000000001"
  subscription_id = "00000000-0000-0000-0000-000000000002"
}

run "uses_cost_conscious_monitoring_defaults" {
  command = plan

  assert {
    condition     = azurerm_log_analytics_workspace.platform.retention_in_days == 30
    error_message = "The lab workspace must use 30-day retention."
  }

  assert {
    condition     = azurerm_log_analytics_workspace.platform.daily_quota_gb == 0.1
    error_message = "The lab workspace must keep the 0.1 GB emergency daily cap."
  }

  assert {
    condition     = length(local.activity_log_categories) == 7
    error_message = "The subscription diagnostic setting must use the reviewed category inventory."
  }

  assert {
    condition     = !azurerm_log_analytics_workspace.platform.local_authentication_enabled
    error_message = "Local workspace authentication must remain disabled."
  }
}
