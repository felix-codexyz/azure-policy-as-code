# Variables for Azure Storage Account Module

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-storage-demo"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "Australia East"
  
  validation {
    condition = contains([
      "Australia East", "Australia Southeast", "Australia Central", "Australia Central 2",
      "East US", "East US 2", "West US", "West US 2", "West US 3", "Central US",
      "North Central US", "South Central US", "West Central US", "Canada Central",
      "Canada East", "Brazil South", "UK South", "UK West", "West Europe", "North Europe",
      "France Central", "France South", "Germany West Central", "Germany North",
      "Norway East", "Norway West", "Switzerland North", "Switzerland West",
      "Sweden Central", "Sweden South", "UAE North", "UAE Central", "South Africa North",
      "South Africa West", "East Asia", "Southeast Asia", "Japan East", "Japan West",
      "Korea Central", "Korea South", "Central India", "South India", "West India",
      "Jio India West", "Jio India Central"
    ], var.location)
    error_message = "The location must be a valid Azure region."
  }
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
  default     = "stdemopolicytest001"
  
  validation {
    condition = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "Storage account name must be between 3 and 24 characters long and can contain only lowercase letters and numbers."
  }
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
  
  validation {
    condition = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either Standard or Premium."
  }
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
  
  validation {
    condition = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS."
  }
}

variable "create_container" {
  description = "Whether to create a storage container"
  type        = bool
  default     = true
}

variable "container_name" {
  description = "Name of the storage container"
  type        = string
  default     = "demo-container"
  
  validation {
    condition = can(regex("^[a-z0-9-]{3,63}$", var.container_name))
    error_message = "Container name must be between 3 and 63 characters long and can contain only lowercase letters, numbers, and hyphens."
  }
}

variable "container_access_type" {
  description = "Access type for the storage container"
  type        = string
  default     = "private"
  
  validation {
    condition = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "Container access type must be one of: private, blob, container."
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Demo"
    Purpose     = "Policy Testing"
    ManagedBy   = "Terraform"
    Project     = "Azure Policy as Code"
  }
}

