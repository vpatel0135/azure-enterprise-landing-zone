locals {
  management_group_scope = "/providers/Microsoft.Management/managementGroups/${var.management_group_name}"
  subscription_scope     = "/subscriptions/${var.subscription_id}"

  groups = {
    platform_readers = {
      display_name = "sg-alz-platform-readers"
      description  = "Read-only visibility across the landing-zone management-group hierarchy."
    }
    platform_operators = {
      display_name = "sg-alz-platform-operators"
      description  = "Manage platform resources in the lab subscription without granting access administration."
    }
    policy_admins = {
      display_name = "sg-alz-policy-admins"
      description  = "Manage Azure Policy resources beneath the landing-zone management group."
    }
    access_admins = {
      display_name = "sg-alz-access-admins"
      description  = "Manage Azure RBAC beneath the landing-zone management group in the lab profile."
    }
  }

  role_assignments = {
    platform_readers = {
      principal_key      = "platform_readers"
      role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7"
      scope              = local.management_group_scope
    }
    platform_operators = {
      principal_key      = "platform_operators"
      role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      scope              = local.subscription_scope
    }
    policy_admins = {
      principal_key      = "policy_admins"
      role_definition_id = "/providers/Microsoft.Authorization/roleDefinitions/36243c78-bf99-498c-9df9-86d9f8d28608"
      scope              = local.management_group_scope
    }
  }
}

resource "azuread_group" "platform" {
  for_each = local.groups

  display_name     = each.value.display_name
  description      = each.value.description
  security_enabled = true
  mail_enabled     = false
  members          = var.group_member_object_ids

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_role_assignment" "platform" {
  for_each = local.role_assignments

  principal_id                     = azuread_group.platform[each.value.principal_key].object_id
  principal_type                   = "Group"
  role_definition_id               = startswith(each.value.scope, "/subscriptions/") ? "${each.value.scope}${each.value.role_definition_id}" : each.value.role_definition_id
  scope                            = each.value.scope
  skip_service_principal_aad_check = true
}
