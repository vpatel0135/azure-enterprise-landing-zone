locals {
  github_oidc_issuer   = "https://token.actions.githubusercontent.com"
  github_oidc_audience = "api://AzureADTokenExchange"
  subscription_scope   = "/subscriptions/${var.subscription_id}"

  automation_environments = {
    nonproduction = {
      code              = "n"
      resource_group_id = module.foundation.resource_groups["nonproduction"].id
      state_container   = "wedding-nonproduction"
    }
    production = {
      code              = "p"
      resource_group_id = module.foundation.resource_groups["production"].id
      state_container   = "wedding-production"
    }
  }

  automation_identities = merge(
    {
      for environment, configuration in local.automation_environments : "${environment}-plan" => {
        environment       = environment
        kind              = "plan"
        display_name      = "id-wed-${configuration.code}-plan"
        subject           = "repo:${var.github_repository}:ref:refs/heads/main"
        resource_group_id = configuration.resource_group_id
        state_container   = configuration.state_container
      }
    },
    {
      for environment, configuration in local.automation_environments : "${environment}-apply" => {
        environment       = environment
        kind              = "apply"
        display_name      = "id-wed-${configuration.code}-apply"
        subject           = "repo:${var.github_repository}:environment:wedding-${environment}"
        resource_group_id = configuration.resource_group_id
        state_container   = configuration.state_container
      }
    }
  )

  state_storage_account_scope = "${local.subscription_scope}/resourceGroups/${var.state_resource_group_name}/providers/Microsoft.Storage/storageAccounts/${var.state_storage_account_name}"
}

resource "azuread_application" "automation" {
  for_each = local.automation_identities

  display_name            = each.value.display_name
  description             = "${title(each.value.kind)} identity for the Wedding ${each.value.environment} GitHub environment."
  owners                  = var.group_member_object_ids
  prevent_duplicate_names = true
  sign_in_audience        = "AzureADMyOrg"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azuread_service_principal" "automation" {
  for_each = local.automation_identities

  client_id                    = azuread_application.automation[each.key].client_id
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

resource "azuread_application_federated_identity_credential" "automation" {
  for_each = local.automation_identities

  application_id = azuread_application.automation[each.key].id
  display_name   = "github-${each.key}"
  description    = "GitHub Actions OIDC trust for ${each.value.subject}."
  audiences      = [local.github_oidc_audience]
  issuer         = local.github_oidc_issuer
  subject        = each.value.subject
}

resource "azurerm_role_assignment" "automation_resource_group" {
  for_each = local.automation_identities

  scope                            = each.value.resource_group_id
  role_definition_id               = "${local.subscription_scope}/providers/Microsoft.Authorization/roleDefinitions/${each.value.kind == "plan" ? "acdd72a7-3385-48ef-bd42-f606fba81ae7" : "b24988ac-6180-42a0-ab88-20f7382dd24c"}"
  principal_id                     = azuread_service_principal.automation[each.key].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "automation_state" {
  for_each = local.automation_identities

  scope                            = "${local.state_storage_account_scope}/blobServices/default/containers/${each.value.state_container}"
  role_definition_id               = "${local.subscription_scope}/providers/Microsoft.Authorization/roleDefinitions/ba92f5b4-2d11-453d-a403-e96b0029c9fe"
  principal_id                     = azuread_service_principal.automation[each.key].object_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
