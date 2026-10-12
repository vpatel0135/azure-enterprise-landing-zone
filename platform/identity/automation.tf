locals {
  github_oidc_issuer   = "https://token.actions.githubusercontent.com"
  github_oidc_audience = "api://AzureADTokenExchange"

  automation_identities = merge(
    {
      plan = {
        display_name = "id-alz-platform-plan"
        subject      = "repo:${var.github_repository}:ref:refs/heads/main"
        description  = "Read-only Azure identity for trusted platform plans from the main branch."
      }
    },
    var.enable_platform_apply_identity ? {
      apply = {
        display_name = "id-alz-platform-apply"
        subject      = "repo:${var.github_repository}:environment:platform-apply"
        description  = "Azure identity for approved platform applies from the protected GitHub environment."
      }
    } : {}
  )

  automated_state_containers = toset([
    "connectivity",
    "management",
    "organization",
  ])

  state_storage_account_scope = "/subscriptions/${var.subscription_id}/resourceGroups/${var.state_resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.state_storage_account_name}"
  state_container_scopes = {
    for container in local.automated_state_containers : container => "${local.state_storage_account_scope}/blobServices/default/containers/${container}"
  }
}

resource "azuread_application" "platform_automation" {
  for_each = local.automation_identities

  display_name            = each.value.display_name
  description             = each.value.description
  owners                  = var.group_member_object_ids
  prevent_duplicate_names = true
  sign_in_audience        = "AzureADMyOrg"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azuread_service_principal" "platform_automation" {
  for_each = local.automation_identities

  client_id                    = azuread_application.platform_automation[each.key].client_id
  owners                       = var.group_member_object_ids
  account_enabled              = true
  app_role_assignment_required = false

  feature_tags {
    enterprise = true
    hide       = true
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "azuread_application_federated_identity_credential" "platform_automation" {
  for_each = local.automation_identities

  application_id = azuread_application.platform_automation[each.key].id
  display_name   = "github-${each.key}"
  description    = "GitHub Actions OIDC trust for ${each.value.subject}."
  audiences      = [local.github_oidc_audience]
  issuer         = local.github_oidc_issuer
  subject        = each.value.subject
}

resource "azurerm_role_assignment" "platform_plan_reader" {
  scope                            = local.management_group_scope
  role_definition_id               = "/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
  principal_id                     = azuread_service_principal.platform_automation["plan"].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "platform_plan_state" {
  for_each = local.state_container_scopes

  scope                            = each.value
  role_definition_id               = "${local.subscription_scope}/providers/Microsoft.Authorization/roleDefinitions/2a2b9908-6ea1-4ae2-8e65-a410df84e7d1"
  principal_id                     = azuread_service_principal.platform_automation["plan"].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "platform_apply_management_groups" {
  count = var.enable_platform_apply_identity ? 1 : 0

  scope                            = local.management_group_scope
  role_definition_id               = "/providers/Microsoft.Authorization/roleDefinitions/5d58bcaf-24a5-4b20-bdb6-eed9f69fbe4c"
  principal_id                     = azuread_service_principal.platform_automation["apply"].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "platform_apply_policy" {
  count = var.enable_platform_apply_identity ? 1 : 0

  scope                            = local.management_group_scope
  role_definition_id               = "/providers/Microsoft.Authorization/roleDefinitions/36243c78-bf99-498c-9df9-86d9f8d28608"
  principal_id                     = azuread_service_principal.platform_automation["apply"].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "platform_apply_resources" {
  count = var.enable_platform_apply_identity ? 1 : 0

  scope                            = local.subscription_scope
  role_definition_id               = "${local.subscription_scope}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
  principal_id                     = azuread_service_principal.platform_automation["apply"].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "platform_apply_state" {
  for_each = var.enable_platform_apply_identity ? local.state_container_scopes : {}

  scope                            = each.value
  role_definition_id               = "${local.subscription_scope}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
  principal_id                     = azuread_service_principal.platform_automation["apply"].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
