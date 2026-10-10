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

variable "instance" {
  description = "Two-digit state-resource instance. Increment manually if the storage account name is unavailable."
  type        = string
  default     = "01"

  validation {
    condition     = can(regex("^[0-9]{2}$", var.instance)) && var.instance != "00"
    error_message = "instance must be a two-digit value from 01 through 99."
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
