# Outputs for Azure Storage Account Module

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.storage_rg.id
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.storage_rg.name
}

output "resource_group_location" {
  description = "The location of the resource group"
  value       = azurerm_resource_group.storage_rg.location
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.storage_account.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.storage_account.name
}

output "storage_account_primary_location" {
  description = "The primary location of the storage account"
  value       = azurerm_storage_account.storage_account.primary_location
}

output "storage_account_secondary_location" {
  description = "The secondary location of the storage account"
  value       = azurerm_storage_account.storage_account.secondary_location
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the storage account"
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}

output "storage_account_primary_access_key" {
  description = "The primary access key of the storage account"
  value       = azurerm_storage_account.storage_account.primary_access_key
  sensitive   = true
}

output "storage_account_secondary_access_key" {
  description = "The secondary access key of the storage account"
  value       = azurerm_storage_account.storage_account.secondary_access_key
  sensitive   = true
}

output "storage_container_id" {
  description = "The ID of the storage container (if created)"
  value       = var.create_container ? azurerm_storage_container.storage_container[0].id : null
}

output "storage_container_name" {
  description = "The name of the storage container (if created)"
  value       = var.create_container ? azurerm_storage_container.storage_container[0].name : null
}

output "storage_container_url" {
  description = "The URL of the storage container (if created)"
  value       = var.create_container ? "${azurerm_storage_account.storage_account.primary_blob_endpoint}${azurerm_storage_container.storage_container[0].name}" : null
}

