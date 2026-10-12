variable "application_name" {
  description = "Human-readable application name used in governed tags."
  type        = string
}

variable "workload_code" {
  description = "Registered compact workload code used in Azure resource names."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,9}$", var.workload_code))
    error_message = "workload_code must contain 2-10 lowercase alphanumeric characters and begin with a letter."
  }
}

variable "location" {
  description = "Azure region for the workload foundation."
  type        = string
  default     = "eastus2"

  validation {
    condition     = var.location == "eastus2"
    error_message = "The initial lab workload foundation is approved for eastus2 only."
  }
}

variable "operator_group_object_id" {
  description = "Microsoft Entra group receiving Contributor on the workload resource groups."
  type        = string

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.operator_group_object_id))
    error_message = "operator_group_object_id must be a Microsoft Entra object UUID."
  }
}

variable "tags" {
  description = "Additional non-sensitive tags merged with the governed workload tags."
  type        = map(string)
  default     = {}
}
