# Azure Policy as Code - Main Configuration
# This module creates and assigns an Azure Policy to restrict resource creation to East US region only

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
      name = "azure-policy-module"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Data source to get current subscription information
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

# Local values for policy configuration
locals {
  policy_name        = "restrict-resources-to-east-us"
  policy_display_name = "Restrict Resource Creation to East US Region Only"
  assignment_name    = "${local.policy_name}-assignment"
  assignment_display_name = "East US Region Restriction Assignment"
}

# Create the custom Azure Policy Definition
resource "azurerm_policy_definition" "restrict_region" {
  name         = local.policy_name
  policy_type  = "Custom"
  mode         = "All"
  display_name = local.policy_display_name
  description  = "This policy restricts the creation of Azure resources to only the East US region. Any attempt to create resources in other regions will be denied."

  metadata = jsonencode({
    version   = "1.0.0"
    category  = "General"
    createdBy = "DevOps Team"
    createdOn = "2025-01-18"
  })

  policy_rule = file("${path.module}/policy_definition.json")

  parameters = jsonencode({
    allowedLocations = {
      type = "Array"
      metadata = {
        displayName = "Allowed Locations"
        description = "The list of locations that can be specified when deploying resources"
        strongType  = "location"
      }
      defaultValue = [
        "eastus"
      ]
    }
    effect = {
      type = "String"
      metadata = {
        displayName = "Effect"
        description = "Enable or disable the execution of the policy"
      }
      allowedValues = [
        "Audit",
        "Deny",
        "Disabled"
      ]
      defaultValue = "Deny"
    }
  })
}

# Assign the policy to the subscription
resource "azurerm_subscription_policy_assignment" "restrict_region" {
  name                 = local.assignment_name
  policy_definition_id = azurerm_policy_definition.restrict_region.id
  subscription_id      = data.azurerm_subscription.current.id
  display_name         = local.assignment_display_name
  description          = "Assignment of the East US region restriction policy to the current subscription"

  # Policy parameters - restrict to East US only
  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_locations
    }
    effect = {
      value = var.policy_effect
    }
  })

  # Metadata for the assignment
  metadata = jsonencode({
    assignedBy = "Terraform"
    assignedOn = timestamp()
    category   = "Compliance"
  })

  # Enable enforcement
  enforce = var.enforce_policy
}

# Optional: Create a policy exemption for specific resource groups if needed
resource "azurerm_resource_group_policy_exemption" "management_exemption" {
  count                = var.create_management_exemption ? 1 : 0
  name                 = "management-rg-exemption"
  resource_group_id    = var.management_resource_group_id
  policy_assignment_id = azurerm_subscription_policy_assignment.restrict_region.id
  exemption_category   = "Waiver"
  display_name         = "Management Resource Group Exemption"
  description          = "Exemption for management resource group to allow cross-region resources"
  
  expires_on = var.exemption_expiry_date
}

