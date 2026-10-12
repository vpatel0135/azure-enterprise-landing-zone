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

variable "github_repository" {
  description = "GitHub owner/repository trusted by workload identity federation."
  type        = string
  default     = "vpatel0135/azure-enterprise-landing-zone"

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "github_repository must use owner/repository format."
  }
}

variable "state_resource_group_name" {
  description = "Resource group containing the Terraform state storage account."
  type        = string
  default     = "rg-eus2p-state-01"
}

variable "state_storage_account_name" {
  description = "Storage account containing the platform Terraform state containers."
  type        = string
  default     = "steus2pstate01"
}

variable "enable_platform_apply_identity" {
  description = "Create the GitHub-trusted platform write identity. This is false until its external trust and write-role blast radius receive explicit approval."
  type        = bool
  default     = false
}
