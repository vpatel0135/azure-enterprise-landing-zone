output "management_group_hierarchy" {
  description = "Stable management-group IDs, display names, and logical parents."
  value = {
    for key, group in local.hierarchy : key => {
      id           = local.management_group_ids[key]
      display_name = group.display_name
      parent       = group.parent
    }
  }
}

output "subscription_placements" {
  description = "Selected profile's logical subscription placements."
  value = {
    for key, placement in local.subscription_placements : key => {
      management_group = placement.management_group_key
      subscription_id  = placement.subscription_id
    }
  }
}

output "profile" {
  description = "Applied organization deployment profile."
  value       = var.profile
}

output "policy_baseline" {
  description = "Non-sensitive configuration of the organizational audit baseline."
  value = {
    assignment_scope_management_group = local.management_group_ids.root
    allowed_locations                 = var.allowed_locations
    location_effect                   = var.location_policy_effect
    tag_effect                        = var.tag_policy_effect
    required_tag_names                = sort(tolist(var.required_tag_names))
  }
}
