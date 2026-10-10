locals {
  region_environment   = "${var.region_code}${var.environment_code}"
  resource_group_name  = "rg-${local.region_environment}-state-${var.resource_group_instance}"
  storage_account_name = "st${local.region_environment}state${var.storage_account_instance}"

  required_tags = {
    application         = "terraform-state"
    environment         = var.environment_code == "p" ? "production" : "nonproduction"
    owner-group         = "sg-alz-platform-operators"
    cost-center         = "portfolio-demo"
    managed-by          = "terraform"
    criticality         = "high"
    data-classification = "confidential"
  }

  state_containers = toset([
    "bootstrap",
    "connectivity",
    "management",
    "organization",
    "workload-foundations",
  ])
}

resource "azurerm_resource_group" "state" {
  name     = local.resource_group_name
  location = var.location
  tags     = merge(var.tags, local.required_tags)
}

resource "azurerm_storage_account" "state" {
  name                = local.storage_account_name
  resource_group_name = azurerm_resource_group.state.name
  location            = azurerm_resource_group.state.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  allow_nested_items_to_be_public   = false
  cross_tenant_replication_enabled  = false
  infrastructure_encryption_enabled = true
  local_user_enabled                = false
  min_tls_version                   = "TLS1_2"
  public_network_access_enabled     = var.public_network_access_enabled
  shared_access_key_enabled         = false

  blob_properties {
    versioning_enabled = true

    container_delete_retention_policy {
      days = 14
    }

    delete_retention_policy {
      days = 14
    }
  }

  tags = merge(var.tags, local.required_tags)
}

resource "azurerm_role_assignment" "bootstrap_state_access" {
  scope                = azurerm_storage_account.state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.bootstrap_principal_object_id
}

resource "azurerm_storage_container" "state" {
  for_each = local.state_containers

  name                  = each.value
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"

  depends_on = [azurerm_role_assignment.bootstrap_state_access]
}
