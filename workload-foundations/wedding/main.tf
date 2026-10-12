resource "azuread_group" "operators" {
  display_name     = "sg-wed-operators"
  description      = "Operate Wedding application resources in the governed production and non-production resource groups."
  security_enabled = true
  mail_enabled     = false
  members          = var.group_member_object_ids

  lifecycle {
    prevent_destroy = true
  }
}

module "foundation" {
  source = "../../modules/workload-foundation"

  application_name         = "wedding-site"
  workload_code            = "wed"
  location                 = var.location
  operator_group_object_id = azuread_group.operators.object_id
  tags                     = var.tags
}
