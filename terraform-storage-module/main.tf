# Terraform Module for Azure Storage Account
# This module deploys an Azure Storage Account in the specified region.

resource "azurerm_resource_group" "storage_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "storage_account" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.storage_rg.name
  location                 = azurerm_resource_group.storage_rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  tags                     = var.tags

  # Optional: Network rules
  # network_rules {
  #   default_action             = "Deny"
  #   ip_rules                   = ["10.0.0.0/24"]
  #   virtual_network_subnet_ids = []
  #   bypass                     = ["AzureServices"]
  # }

  # Optional: Blob properties
  # blob_properties {
  #   change_feed_enabled      = false
  #   versioning_enabled       = false
  #   last_access_time_enabled = false
  # }
}

resource "azurerm_storage_container" "storage_container" {
  count                 = var.create_container ? 1 : 0
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = var.container_access_type
}

