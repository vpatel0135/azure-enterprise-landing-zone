variable "tenant_id" {
  description = "Microsoft Entra tenant used to deploy connectivity."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.tenant_id))
    error_message = "tenant_id must be a Microsoft Entra tenant UUID."
  }
}

variable "subscription_id" {
  description = "Subscription containing the lab connectivity resources."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be an Azure subscription UUID."
  }
}

variable "location" {
  description = "Azure region for the initial connectivity baseline."
  type        = string
  default     = "eastus2"

  validation {
    condition     = var.location == "eastus2"
    error_message = "The initial connectivity baseline is approved for eastus2 only."
  }
}

variable "tags" {
  description = "Additional non-sensitive tags merged with governed tags."
  type        = map(string)
  default     = {}
}
