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
