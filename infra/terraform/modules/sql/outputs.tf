output "connection_string" {
  value     = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=EcommerceOrders;User ID=sqladmin;Password=${var.sql_admin_password}"
  sensitive = true
}
