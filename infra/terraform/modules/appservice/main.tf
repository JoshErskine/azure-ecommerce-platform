resource "azurerm_service_plan" "main" {
  name                = "asp-${var.prefix}-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Linux"
  sku_name            = "B1"

  tags = var.tags
}

resource "azurerm_linux_web_app" "main" {
  name                = "${var.prefix}-api-${var.environment}"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.main.id

  # System-assigned managed identity (no passwords needed)
  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }

  app_settings = {
    "KeyVaultName" = var.key_vault_name
    "ASPNETCORE_ENVIRONMENT" = var.environment == "prod" ? "Production" : "Development"
  }

  tags = var.tags
}

output "principal_id" {
  value = azurerm_linux_web_app.main.identity[0].principal_id
}

output "default_hostname" {
  value = azurerm_linux_web_app.main.default_hostname
}

output "service_plan_id" {
  value = azurerm_service_plan.main.id
}
