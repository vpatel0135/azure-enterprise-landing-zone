mock_provider "azurerm" {}

variables {
  tenant_id                  = "00000000-0000-0000-0000-000000000001"
  deployment_subscription_id = "00000000-0000-0000-0000-000000000002"
  profile                    = "lab"
  lab_subscription_id        = "00000000-0000-0000-0000-000000000003"
}

run "lab_hierarchy_and_placement" {
  command = plan

  assert {
    condition     = output.management_group_hierarchy.online.parent == "landing_zones"
    error_message = "Online must inherit from Landing Zones."
  }

  assert {
    condition     = output.management_group_hierarchy.management.parent == "platform"
    error_message = "Management must inherit from Platform."
  }

  assert {
    condition     = output.subscription_placements.lab.management_group == "root"
    error_message = "The lab subscription must be placed directly beneath alz-example."
  }
}

run "enterprise_rejects_shared_environment_subscription" {
  command = plan

  variables {
    profile             = "enterprise"
    lab_subscription_id = null
    enterprise_subscription_ids = {
      management                 = "00000000-0000-0000-0000-000000000010"
      connectivity               = "00000000-0000-0000-0000-000000000011"
      webportfolio_production    = "00000000-0000-0000-0000-000000000012"
      webportfolio_nonproduction = "00000000-0000-0000-0000-000000000012"
    }
  }

  expect_failures = [check.enterprise_subscription_ids_are_distinct]
}
