mock_provider "azuread" {}
mock_provider "azurerm" {}

variables {
  tenant_id       = "00000000-0000-0000-0000-000000000001"
  subscription_id = "00000000-0000-0000-0000-000000000002"
}

run "creates_isolated_environment_foundations" {
  command = plan

  assert {
    condition     = length(module.foundation.resource_groups) == 2
    error_message = "Wedding must have separate production and non-production resource groups."
  }

  assert {
    condition     = module.foundation.resource_groups["production"].name == "rg-eus2p-wed-01"
    error_message = "The production resource-group name must follow ADR-0007."
  }

  assert {
    condition     = module.foundation.resource_groups["nonproduction"].name == "rg-eus2n-wed-01"
    error_message = "The non-production resource-group name must follow ADR-0007."
  }

  assert {
    condition     = azuread_group.operators.display_name == "sg-wed-operators"
    error_message = "Human access must be assigned through the Wedding operator group."
  }

  assert {
    condition     = length(azuread_application.automation) == 4
    error_message = "Wedding must use separate plan/apply identities for production and non-production."
  }

  assert {
    condition     = azuread_application_federated_identity_credential.automation["production-apply"].subject == "repo:vpatel0135/VS-Wedding-2026:environment:wedding-production"
    error_message = "Production apply must trust only the Wedding production GitHub environment."
  }

  assert {
    condition     = endswith(azurerm_role_assignment.automation_resource_group["production-apply"].role_definition_id, "/b24988ac-6180-42a0-ab88-20f7382dd24c")
    error_message = "Production apply must use Contributor rather than an access-administrator role."
  }
}
