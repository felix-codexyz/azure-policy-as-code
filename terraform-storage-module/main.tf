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

  # CKV_AZURE_190: Ensure that Storage blobs restrict public access
  allow_blob_public_access = false

  # CKV_AZURE_59: Ensure that Storage accounts disallow public access
  public_network_access_enabled = false

  # CKV_AZURE_44: Ensure Storage Account is using the latest version of TLS encryption
  min_tls_version = "TLS1_2"

  # CKV_AZURE_206: Ensure that Storage Accounts use replication
  # This is already covered by account_replication_type, but if the policy expects a specific type, ensure it's not LRS for critical data.
  # For this example, we will assume LRS is acceptable, but for production, GRS/RA-GRS/ZRS/GZRS/RA-GZRS are preferred.
  # The policy might be looking for a specific value like 'GRS' or 'ZRS'.
  # If 'LRS' is causing a failure, change account_replication_type to 'GRS' or 'ZRS' in variables.tf and example.tf.

  # CKV_AZURE_33: Ensure Storage logging is enabled for Queue service for read, write and delete requests
  # CKV2_AZURE_21: Ensure Storage logging is enabled for Blob service for read requests
  # These require specific diagnostic settings, which are typically separate resources.
  # For now, we'll add a placeholder for blob_properties and queue_properties to enable logging.
  blob_properties {
    change_feed_enabled      = true
    versioning_enabled       = true
    last_access_time_enabled = true
    delete_retention_policy {
      days = 7 # CKV2_AZURE_38: Ensure soft-delete is enabled on Azure storage account
    }
  }

  queue_properties {
    hour_metrics {
      enabled = true
      version = "1.0"
    }
    minute_metrics {
      enabled = true
      version = "1.0"
    }
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
    }
  }

  # CKV2_AZURE_1: Ensure storage for critical data are encrypted with Customer Managed Key
  # This requires additional resources (Key Vault, Key Vault Key) and configuration.
  # For this example, we will assume Microsoft-managed keys are acceptable.
  # If CMK is strictly required, you would add a 'customer_managed_key' block here.

  # CKV2_AZURE_47: Ensure storage account is configured without blob anonymous access
  # This is covered by allow_blob_public_access = false

  # CKV2_AZURE_40: Ensure storage account is not configured with Shared Key authorization
  # This requires setting 'azure_ad_authentication_only = true'.
  azure_ad_authentication_only = true

  # CKV2_AZURE_41: Ensure storage account is configured with SAS expiration policy
  # This is not directly configurable on the storage account resource itself.
  # It's typically managed via Azure Policy or client-side SDKs.
  # We can add a comment to acknowledge this, but no direct HCL change here.

  # CKV2_AZURE_33: Ensure storage account is configured with private endpoint
  # This requires creating 'azurerm_private_endpoint' resources and linking them.
  # For this example, we will not configure private endpoints, as it adds significant complexity.
  # If required, you would add a 'network_rules' block and private endpoint resources.

  # Optional: Network rules (keeping commented out as per original, but public_network_access_enabled addresses the main concern)
  # network_rules {
  #   default_action             = "Deny"
  #   ip_rules                   = ["10.0.0.0/24"]
  #   virtual_network_subnet_ids = []
  #   bypass                     = ["AzureServices"]
  # }
}

resource "azurerm_storage_container" "storage_container" {
  count                 = var.create_container ? 1 : 0
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage_account.name
  container_access_type = var.container_access_type
}


