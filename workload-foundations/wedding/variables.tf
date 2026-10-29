variable "tenant_id" {
  description = "Microsoft Entra tenant containing the workload operator group."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.tenant_id))
    error_message = "tenant_id must be a Microsoft Entra tenant UUID."
  }
}

variable "subscription_id" {
  description = "Lab subscription containing the wedding workload resource groups."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be an Azure subscription UUID."
  }
}

variable "group_member_object_ids" {
  description = "Existing Microsoft Entra object IDs added to the wedding operator group. Keep populated values out of source control."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for object_id in var.group_member_object_ids : can(regex("^[0-9a-fA-F-]{36}$", object_id))])
    error_message = "Every group member object ID must be a UUID."
  }
}

variable "location" {
  description = "Azure region for the wedding workload foundation."
  type        = string
  default     = "eastus2"
}

variable "tags" {
  description = "Additional non-sensitive tags merged with governed workload tags."
  type        = map(string)
  default     = {}
}

variable "github_repository" {
  description = "GitHub owner/repository trusted by the Wedding workload identities."
  type        = string
  default     = "vpatel0135@300160549/azure-wedding-guest-demo@1416362671"

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+(@[0-9]+)?/[A-Za-z0-9_.-]+(@[0-9]+)?$", var.github_repository))
    error_message = "github_repository must use owner/repository format, optionally with immutable @ID suffixes."
  }
}

variable "state_resource_group_name" {
  description = "Resource group containing the Wedding Terraform state containers."
  type        = string
  default     = "rg-eus2p-state-01"
}

variable "state_storage_account_name" {
  description = "Storage account containing the Wedding Terraform state containers."
  type        = string
  default     = "steus2pstate01"
}
