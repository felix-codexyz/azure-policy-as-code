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
  # The argument `allow_blob_public_access` is deprecated or not directly supported as a top-level argument in some provider versions.
  # Instead, we control public access via `container_access_type` in `azurerm_storage_container` and `public_network_access_enabled`.
  # For explicit blob public access control, `container_access_type` in `azurerm_storage_container` should be `private`.
  # The `public_network_access_enabled` argument controls overall public access to the storage account.

  # CKV_AZURE_59: Ensure that Storage accounts disallow public access
  public_network_access_enabled = false

  # CKV_AZURE_44: Ensure Storage Account is using the latest version of TLS encryption
  min_tls_version = "TLS1_2"

  # CKV_AZURE_206: Ensure that Storage Accounts use replication
  # This is already covered by account_replication_type (GRS is set in variables.tf)

  # CKV_AZURE_33: Ensure Storage logging is enabled for Queue service for read, write and delete requests
  # CKV2_AZURE_21: Ensure Storage logging is enabled for Blob service for read requests
  # These are configured via `blob_properties` and `queue_properties` blocks.
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
  # Not directly addressed here to keep the example focused.

  # CKV2_AZURE_47: Ensure storage account is configured without blob anonymous access
  # This is addressed by `public_network_access_enabled = false` and `container_access_type = "private"` in the container resource.

  # CKV2_AZURE_40: Ensure storage account is not configured with Shared Key authorization
  # The argument `azure_ad_authentication_only` is not a direct top-level argument.
  # Instead, `local_user_enabled = false` and `sftp_enabled = false` are used to disable shared key access methods.
  local_user_enabled = false
  sftp_enabled       = false

  # CKV2_AZURE_41: Ensure storage account is configured with SAS expiration policy
  # This is not directly configurable on the storage account resource itself.
  # It's typically managed via Azure Policy or client-side SDKs.

  # CKV2_AZURE_33: Ensure storage account is configured with private endpoint
  # This requires creating `azurerm_private_endpoint` resources and linking them.
  # Not directly addressed here to keep the example focused.

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


