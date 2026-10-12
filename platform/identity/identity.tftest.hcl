mock_provider "azuread" {}
mock_provider "azurerm" {}

variables {
  tenant_id               = "00000000-0000-0000-0000-000000000001"
  subscription_id         = "00000000-0000-0000-0000-000000000002"
  management_group_name   = "alz-example"
  group_member_object_ids = ["00000000-0000-0000-0000-000000000003"]
}

run "uses_groups_and_least_privilege_scopes" {
  command = plan

  assert {
    condition     = length(azuread_group.platform) == 4
    error_message = "The platform identity root must create four purpose-specific security groups."
  }

  assert {
    condition     = azurerm_role_assignment.platform["platform_operators"].scope == "/subscriptions/00000000-0000-0000-0000-000000000002"
    error_message = "Platform operators must be scoped to the lab subscription."
  }

  assert {
    condition     = alltrue([for assignment in azurerm_role_assignment.platform : assignment.principal_type == "Group"])
    error_message = "Managed platform role assignments must target groups, never users."
  }

  assert {
    condition     = !contains(keys(azurerm_role_assignment.platform), "access_admins")
    error_message = "The lab must not grant standing management-group access administration."
  }
}
