variable "tenant_id" {
  description = "Microsoft Entra tenant used to deploy the management layer."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.tenant_id))
    error_message = "tenant_id must be a Microsoft Entra tenant UUID."
  }
}

variable "subscription_id" {
  description = "Subscription that contains the lab management resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be an Azure subscription UUID."
  }
}

variable "location" {
  description = "Azure region for the initial management layer."
  type        = string
  default     = "eastus2"

  validation {
    condition     = var.location == "eastus2"
    error_message = "The initial lab management layer is approved for eastus2 only."
  }
}

variable "daily_quota_gb" {
  description = "Emergency daily ingestion cap in GB; collection stops after Azure processes the cap."
  type        = number
  default     = 0.1

  validation {
    condition     = var.daily_quota_gb >= 0.1 && var.daily_quota_gb <= 1
    error_message = "The lab daily quota must remain between 0.1 and 1 GB."
  }
}

variable "tags" {
  description = "Additional non-sensitive tags merged with the governed platform tags."
  type        = map(string)
  default     = {}
}
