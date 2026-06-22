resource "azurerm_api_management" "main" {
  name                = "${var.prefix}-apim-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Consumption_0"

  tags = var.tags
}

resource "azurerm_api_management_api" "ecommerce" {
  name                = "ecommerce-api"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.main.name
  revision            = "1"
  display_name        = "E-Commerce API"
  path                = "ecommerce"
  protocols           = ["https"]
  service_url         = "https://${var.app_service_hostname}"

  import {
    content_format = "openapi-link"
    content_value  = "https://${var.app_service_hostname}/swagger/v1/swagger.json"
  }
}
