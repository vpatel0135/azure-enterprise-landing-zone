variable "subscription_id" {
  description = "Azure subscription that owns the Terraform state resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be an Azure subscription UUID."
  }
}

variable "tenant_id" {
  description = "Microsoft Entra tenant used to deploy the state resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.tenant_id))
    error_message = "tenant_id must be a Microsoft Entra tenant UUID."
  }
}

variable "location" {
  description = "Azure region for the state resource group and storage account."
  type        = string
  default     = "eastus2"

  validation {
    condition     = contains(["eastus2"], var.location)
    error_message = "The initial lab profile permits eastus2 only. Extend the accepted region catalog before using another region."
  }
}

variable "region_code" {
  description = "Repository-owned code for the selected Azure region."
  type        = string
  default     = "eus2"

  validation {
    condition     = var.region_code == "eus2"
    error_message = "The region code must match the accepted eastus2 mapping: eus2."
  }
}

variable "environment_code" {
  description = "Single-letter lifecycle code used in resource names."
  type        = string
  default     = "p"

  validation {
    condition     = contains(["p", "n", "d", "t", "s", "x"], var.environment_code)
    error_message = "environment_code must be one of p, n, d, t, s, or x."
  }
}

variable "bootstrap_principal_object_id" {
  description = "Microsoft Entra object ID granted data-plane access to bootstrap state."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.bootstrap_principal_object_id))
    error_message = "bootstrap_principal_object_id must be a Microsoft Entra object UUID."
  }
}

variable "resource_group_instance" {
  description = "Two-digit resource-group instance."
  type        = string
  default     = "01"

  validation {
    condition     = can(regex("^[0-9]{2}$", var.resource_group_instance)) && var.resource_group_instance != "00"
    error_message = "resource_group_instance must be a two-digit value from 01 through 99."
  }
}

variable "storage_account_instance" {
  description = "Two-digit storage-account instance. Increment manually if its global name is unavailable."
  type        = string
  default     = "01"

  validation {
    condition     = can(regex("^[0-9]{2}$", var.storage_account_instance)) && var.storage_account_instance != "00"
    error_message = "storage_account_instance must be a two-digit value from 01 through 99."
  }
}

variable "public_network_access_enabled" {
  description = "Allow access through the storage account public endpoint. Required initially for GitHub-hosted runners unless a private runner path exists."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional non-sensitive tags merged with the required state-resource tags."
  type        = map(string)
  default     = {}
}
