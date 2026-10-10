variable "resource_type" {
  description = "Approved resource-type abbreviation, such as rg, asp, st, law, or vnet."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,7}$", var.resource_type))
    error_message = "resource_type must contain 2-8 lowercase alphanumeric characters and begin with a letter."
  }
}

variable "region_code" {
  description = "Approved region code from the repository registry."
  type        = string

  validation {
    condition     = contains(["eus2"], var.region_code)
    error_message = "region_code must be registered; the initial registry contains eus2."
  }
}

variable "environment_code" {
  description = "Single-letter lifecycle code."
  type        = string

  validation {
    condition     = contains(["p", "n", "d", "t", "s", "x"], var.environment_code)
    error_message = "environment_code must be one of p, n, d, t, s, or x."
  }
}

variable "workload_code" {
  description = "Registered application or platform-capability code."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{1,9}$", var.workload_code))
    error_message = "workload_code must contain 2-10 lowercase alphanumeric characters and begin with a letter."
  }
}

variable "instance" {
  description = "Two-digit sequence maintained independently per resource type."
  type        = string
  default     = "01"

  validation {
    condition     = can(regex("^[0-9]{2}$", var.instance)) && var.instance != "00"
    error_message = "instance must be a two-digit value from 01 through 99."
  }
}

variable "use_hyphens" {
  description = "Use the readable hyphenated format. Set false for resource types that prohibit hyphens."
  type        = bool
  default     = true
}
