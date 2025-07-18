# Outputs for Azure Policy Module

output "policy_definition_id" {
  description = "The ID of the created policy definition"
  value       = azurerm_policy_definition.restrict_region.id
}

output "policy_definition_name" {
  description = "The name of the created policy definition"
  value       = azurerm_policy_definition.restrict_region.name
}

output "policy_assignment_id" {
  description = "The ID of the policy assignment"
  value       = azurerm_subscription_policy_assignment.restrict_region.id
}

output "policy_assignment_name" {
  description = "The name of the policy assignment"
  value       = azurerm_subscription_policy_assignment.restrict_region.name
}

output "subscription_id" {
  description = "The subscription ID where the policy is assigned"
  value       = data.azurerm_subscription.current.subscription_id
}

output "allowed_locations" {
  description = "The list of allowed locations configured in the policy"
  value       = var.allowed_locations
}

output "policy_effect" {
  description = "The effect of the policy (Audit, Deny, or Disabled)"
  value       = var.policy_effect
}

output "policy_enforcement_status" {
  description = "Whether the policy is being enforced"
  value       = var.enforce_policy
}

output "exemption_created" {
  description = "Whether a management exemption was created"
  value       = var.create_management_exemption
}

output "exemption_id" {
  description = "The ID of the policy exemption (if created)"
  value       = var.create_management_exemption ? azurerm_resource_group_policy_exemption.management_exemption[0].id : null
}

