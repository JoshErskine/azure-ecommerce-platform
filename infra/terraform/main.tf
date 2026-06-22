terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # Remote state — stores terraform.tfstate in Azure Blob Storage
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "ecomtfstate"
    container_name       = "tfstate"
    key                  = "ecommerce.dev.tfstate"
  }
}

provider "azurerm" {
  features {
    key_vault {
      # Prevents accidental Key Vault deletion
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Resource Group — the container for all other resources
resource "azurerm_resource_group" "main" {
  name     = "rg-ecommerce-${var.environment}"
  location = var.location
   tags = {
    environment = var.environment
    project     = "ecommerce-platform"
    managed_by  = "terraform"
  }
}
  