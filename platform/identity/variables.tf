variable "tenant_id" {
  description = "Microsoft Entra tenant containing the landing-zone groups."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.tenant_id))
    error_message = "tenant_id must be a Microsoft Entra tenant UUID."
  }
}

variable "subscription_id" {
  description = "Lab subscription where platform operators manage Azure resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be an Azure subscription UUID."
  }
}

variable "management_group_name" {
  description = "Name of the landing-zone management group that bounds governance access."
  type        = string
  default     = "alz-example"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,30}[a-z0-9]$", var.management_group_name))
    error_message = "management_group_name must be 3-32 lowercase letters, numbers, or hyphens."
  }
}

variable "group_member_object_ids" {
  description = "Existing Microsoft Entra user or service-principal object IDs added to the lab groups. Keep populated values out of the public repository."
  type        = set(string)
  default     = []

  validation {
    condition     = alltrue([for object_id in var.group_member_object_ids : can(regex("^[0-9a-fA-F-]{36}$", object_id))])
    error_message = "Every group member object ID must be a UUID."
  }
}
