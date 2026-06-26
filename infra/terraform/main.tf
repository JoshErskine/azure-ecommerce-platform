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
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
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

locals {
  tags = {
    environment = var.environment
    project     = "ecommerce-platform"
    managed_by  = "terraform"
  }
}

module "cosmos" {
  source              = "./modules/cosmos"
  prefix              = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

module "sql" {
  source              = "./modules/sql"
  prefix              = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  sql_admin_password  = var.sql_admin_password
  tags                = local.tags
}

module "storage" {
  source              = "./modules/storage"
  prefix              = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

module "servicebus" {
  source              = "./modules/servicebus"
  prefix              = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

# App Service must come before Key Vault so we can pass its principal_id
module "appservice" {
  source              = "./modules/appservice"
  prefix              = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  key_vault_name      = "${var.prefix}-kv-${var.environment}"
  tags                = local.tags
}

module "keyvault" {
  source                     = "./modules/keyvault"
  prefix                     = var.prefix
  environment                = var.environment
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  app_service_principal_id   = module.appservice.principal_id
  cosmos_connection_string   = module.cosmos.connection_string
  sql_connection_string      = module.sql.connection_string
  servicebus_connection_string = module.servicebus.connection_string
  tags                       = local.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  prefix              = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

module "functions" {
  source                      = "./modules/functions"
  prefix                      = var.prefix
  environment                 = var.environment
  location                    = var.location
  resource_group_name         = azurerm_resource_group.main.name
  storage_account_name        = module.storage.account_name
  storage_account_key         = module.storage.primary_access_key
  storage_connection_string   = module.storage.connection_string
  servicebus_connection_string = module.servicebus.connection_string
  blob_connection_string      = module.storage.connection_string
  service_plan_id             = module.appservice.service_plan_id
  tags                        = local.tags
}

module "apim" {
  source              = "./modules/apim"
  prefix              = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  publisher_name      = "Josh Erskine"
  publisher_email     = "joshuaerskine0@gmail.com"
  app_service_hostname = module.appservice.default_hostname
  tags                = local.tags
}
  