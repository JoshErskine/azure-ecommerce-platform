resource "azurerm_linux_function_app" "main" {
  name                       = "${var.prefix}-func-${var.environment}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_key
  service_plan_id            = var.service_plan_id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version            = "8.0"
      use_dotnet_isolated_runtime = true
    }
  }

  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME"    = "dotnet-isolated"
    "ServiceBusConnectionString"  = var.servicebus_connection_string
    "BlobStorageConnectionString" = var.blob_connection_string
    "AzureWebJobsStorage"         = var.storage_connection_string
  }

  tags = var.tags
}
