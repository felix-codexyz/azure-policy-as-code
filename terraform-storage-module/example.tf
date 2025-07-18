# Example usage of Azure Storage Account Module

module "storage_account_example" {
  source = "."

  resource_group_name      = "rg-policy-test-storage"
  location                 = "Australia East"
  storage_account_name     = "stpolicydemo001"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  create_container         = true
  container_name           = "my-test-container"

  tags = {
    Environment = "Development"
    Project     = "PolicyDemo"
  }
}

