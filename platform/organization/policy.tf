data "azurerm_policy_definition" "allowed_locations" {
  name = "e56962a6-4747-49cd-b67b-bf8b01975c4c"
}

resource "azurerm_policy_definition" "required_tag_audit" {
  name                = "alz-example-required-tag-audit"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "ALZ Example: Audit required tag"
  description         = "Audits taggable resources that are missing a required organizational tag."
  management_group_id = azurerm_management_group.root.id

  metadata = jsonencode({
    category = "ALZ Example"
    version  = "1.0.0"
  })

  parameters = jsonencode({
    effect = {
      type = "String"
      metadata = {
        displayName = "Effect"
        description = "Enable auditing or disable the policy."
      }
      allowedValues = ["Audit", "Disabled"]
      defaultValue  = "Audit"
    }
    tagName = {
      type = "String"
      metadata = {
        displayName = "Tag name"
        description = "Required tag key to audit."
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      field  = "[concat('tags[', parameters('tagName'), ']')]"
      exists = "false"
    }
    then = {
      effect = "[parameters('effect')]"
    }
  })
}

resource "azurerm_management_group_policy_set_definition" "organizational_baseline" {
  name                = "alz-example-organizational-baseline"
  policy_type         = "Custom"
  display_name        = "ALZ Example organizational baseline"
  description         = "Initial audit-first baseline for approved Azure locations and required resource metadata."
  management_group_id = azurerm_management_group.root.id

  metadata = jsonencode({
    category = "ALZ Example"
    version  = "1.0.0"
  })

  parameters = jsonencode({
    allowedLocations = {
      type         = "Array"
      defaultValue = ["eastus2"]
      metadata = {
        displayName = "Allowed locations"
        description = "Azure locations approved by the organization."
      }
    }
    locationEffect = {
      type          = "String"
      allowedValues = ["Audit", "Deny", "Disabled"]
      defaultValue  = "Audit"
      metadata = {
        displayName = "Location effect"
        description = "Audit first; promote to Deny only after impact review."
      }
    }
    tagEffect = {
      type          = "String"
      allowedValues = ["Audit", "Disabled"]
      defaultValue  = "Audit"
      metadata = {
        displayName = "Tag effect"
        description = "Audit required resource tags or disable the checks."
      }
    }
  })

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
    reference_id         = "allowed-locations"
    parameter_values = jsonencode({
      effect = {
        value = "[parameters('locationEffect')]"
      }
      listOfAllowedLocations = {
        value = "[parameters('allowedLocations')]"
      }
    })
  }

  dynamic "policy_definition_reference" {
    for_each = var.required_tag_names

    content {
      policy_definition_id = azurerm_policy_definition.required_tag_audit.id
      reference_id         = "required-tag-${policy_definition_reference.value}"
      parameter_values = jsonencode({
        effect = {
          value = "[parameters('tagEffect')]"
        }
        tagName = {
          value = policy_definition_reference.value
        }
      })
    }
  }
}

resource "azurerm_management_group_policy_assignment" "organizational_baseline" {
  name                 = "alz-baseline-audit"
  display_name         = "ALZ Example baseline - audit"
  description          = "Audits approved locations and required metadata before enforcement is considered."
  management_group_id  = azurerm_management_group.root.id
  policy_definition_id = azurerm_management_group_policy_set_definition.organizational_baseline.id
  enforce              = true

  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
    locationEffect = {
      value = var.location_policy_effect
    }
    tagEffect = {
      value = var.tag_policy_effect
    }
  })

  non_compliance_message {
    content = "Resource configuration does not meet the ALZ Example audit baseline. Review the policy reference and approved metadata contract."
  }
}
