resource "azurerm_mssql_server" "main" {
  name                         = "${var.prefix}-sqlserver-${var.environment}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = var.sql_admin_password

  tags = var.tags
}

resource "azurerm_mssql_database" "main" {
  name      = "EcommerceOrders"
  server_id = azurerm_mssql_server.main.id
  sku_name  = "Basic"

  tags = var.tags
}

# Allow Azure services to connect (required for App Service)
resource "azurerm_mssql_firewall_rule" "azure_services" {
  name             = "AllowAzureServices"
  server_id        = azurerm_mssql_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}
