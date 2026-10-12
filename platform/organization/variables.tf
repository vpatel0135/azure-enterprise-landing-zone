variable "tenant_id" {
  description = "Microsoft Entra tenant containing the management-group hierarchy."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "tenant_id must be a Microsoft Entra tenant UUID."
  }
}

variable "deployment_subscription_id" {
  description = "Subscription used to initialize the AzureRM provider. Resources in this root are tenant scoped."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.deployment_subscription_id))
    error_message = "deployment_subscription_id must be an Azure subscription UUID."
  }
}

variable "profile" {
  description = "Deployment profile: lab uses one subscription; enterprise requires separate platform and workload subscriptions."
  type        = string
  default     = "lab"

  validation {
    condition     = contains(["lab", "enterprise"], var.profile)
    error_message = "profile must be either lab or enterprise."
  }
}

variable "management_group_prefix" {
  description = "Stable lowercase prefix used in immutable management-group IDs."
  type        = string
  default     = "alz-example"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.management_group_prefix))
    error_message = "management_group_prefix must be 3-32 lowercase letters, numbers, or hyphens and cannot begin or end with a hyphen."
  }
}

variable "lab_subscription_id" {
  description = "Existing subscription placed directly beneath the top-level management group in the lab profile."
  type        = string
  default     = null
  nullable    = true

  validation {
    condition     = var.lab_subscription_id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.lab_subscription_id))
    error_message = "lab_subscription_id must be null or an Azure subscription UUID."
  }
}

variable "enterprise_subscription_ids" {
  description = "Subscription placement for the enterprise profile. Optional values omit that placement."
  type = object({
    management                 = string
    connectivity               = string
    webportfolio_production    = string
    webportfolio_nonproduction = string
    identity                   = optional(string)
    sandbox                    = optional(string)
  })
  default  = null
  nullable = true
}

variable "allowed_locations" {
  description = "Azure locations audited by the organizational baseline."
  type        = list(string)
  default     = ["eastus2"]

  validation {
    condition     = length(var.allowed_locations) > 0 && alltrue([for location in var.allowed_locations : length(trimspace(location)) > 0])
    error_message = "allowed_locations must contain at least one non-empty Azure location."
  }
}

variable "location_policy_effect" {
  description = "Initial effect for the allowed-locations policy. Promote to Deny only after audit evidence is reviewed."
  type        = string
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Deny", "Disabled"], var.location_policy_effect)
    error_message = "location_policy_effect must be Audit, Deny, or Disabled."
  }
}

variable "tag_policy_effect" {
  description = "Initial effect for required-tag checks."
  type        = string
  default     = "Audit"

  validation {
    condition     = contains(["Audit", "Disabled"], var.tag_policy_effect)
    error_message = "tag_policy_effect must be Audit or Disabled."
  }
}

variable "required_tag_names" {
  description = "Tag keys audited on Azure resources that support tags."
  type        = set(string)
  default = [
    "application",
    "cost-center",
    "criticality",
    "data-classification",
    "environment",
    "managed-by",
    "owner-group",
  ]

  validation {
    condition     = length(var.required_tag_names) > 0 && alltrue([for tag_name in var.required_tag_names : can(regex("^[a-z][a-z0-9-]{1,63}$", tag_name))])
    error_message = "required_tag_names must contain lowercase tag keys using letters, numbers, and hyphens."
  }
}

check "profile_inputs_are_exclusive" {
  assert {
    condition = (
      var.profile == "lab"
      ? var.lab_subscription_id != null && var.enterprise_subscription_ids == null
      : var.lab_subscription_id == null && var.enterprise_subscription_ids != null
    )
    error_message = "lab requires only lab_subscription_id; enterprise requires only enterprise_subscription_ids."
  }
}

check "enterprise_subscription_ids_are_valid" {
  assert {
    condition = var.profile != "enterprise" || alltrue([
      for subscription_id in values(var.enterprise_subscription_ids) :
      subscription_id == null || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", subscription_id))
    ])
    error_message = "Every enterprise subscription value must be an Azure subscription UUID."
  }
}

check "enterprise_subscription_ids_are_distinct" {
  assert {
    condition     = var.profile != "enterprise" || length(compact(values(var.enterprise_subscription_ids))) == length(distinct(compact(values(var.enterprise_subscription_ids))))
    error_message = "Enterprise subscription IDs must be distinct; production and non-production cannot share a subscription."
  }
}
