# Provider configuration for Azure Storage Account Module

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  
  cloud {
    organization = "succpinn-solutions-azure-policy"

    workspaces {
      name = "azure-storage-module"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

