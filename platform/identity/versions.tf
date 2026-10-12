terraform {
  required_version = "= 1.16.5"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "= 3.9.0"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {}
}
