# Variables for Azure Policy Module

variable "allowed_locations" {
  description = "List of allowed Azure regions for resource deployment"
  type        = list(string)
  default     = ["eastus"]
  
  validation {
    condition = length(var.allowed_locations) > 0
    error_message = "At least one location must be specified in allowed_locations."
  }
}

variable "policy_effect" {
  description = "The effect of the policy (Audit, Deny, or Disabled)"
  type        = string
  default     = "Deny"
  
  validation {
    condition = contains(["Audit", "Deny", "Disabled"], var.policy_effect)
    error_message = "Policy effect must be one of: Audit, Deny, or Disabled."
  }
}

variable "enforce_policy" {
  description = "Whether to enforce the policy assignment"
  type        = bool
  default     = true
}

variable "create_management_exemption" {
  description = "Whether to create an exemption for management resource group"
  type        = bool
  default     = false
}

variable "management_resource_group_id" {
  description = "Resource ID of the management resource group for exemption"
  type        = string
  default     = ""
}

variable "exemption_expiry_date" {
  description = "Expiry date for the policy exemption (RFC3339 format)"
  type        = string
  default     = null
}

variable "subscription_id" {
  description = "Azure subscription ID where the policy will be assigned"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to the policy assignment"
  type        = map(string)
  default = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    Purpose     = "Compliance"
  }
}

