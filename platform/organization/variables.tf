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
