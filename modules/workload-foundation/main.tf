locals {
  environments = {
    nonproduction = {
      code        = "n"
      criticality = "low"
    }
    production = {
      code        = "p"
      criticality = "medium"
    }
  }
}

module "resource_group_name" {
  for_each = local.environments
  source   = "../naming"

  resource_type    = "rg"
  region_code      = "eus2"
  environment_code = each.value.code
  workload_code    = var.workload_code
  instance         = "01"
}

resource "azurerm_resource_group" "environment" {
  for_each = local.environments

  name     = module.resource_group_name[each.key].name
  location = var.location
  tags = merge(var.tags, {
    application         = var.application_name
    environment         = each.key
    owner-group         = "sg-${var.workload_code}-operators"
    cost-center         = "portfolio-demo"
    managed-by          = "terraform"
    criticality         = each.value.criticality
    data-classification = "public"
  })
}

resource "azurerm_role_assignment" "operator" {
  for_each = azurerm_resource_group.environment

  scope                            = each.value.id
  role_definition_name             = "Contributor"
  principal_id                     = var.operator_group_object_id
  principal_type                   = "Group"
  skip_service_principal_aad_check = true
}
