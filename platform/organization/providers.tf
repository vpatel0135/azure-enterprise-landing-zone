provider "azurerm" {
  features {}

  subscription_id = var.deployment_subscription_id
  tenant_id       = var.tenant_id
}
