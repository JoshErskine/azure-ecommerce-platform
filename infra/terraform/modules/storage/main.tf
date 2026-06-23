resource "azurerm_storage_account" "main" {
  name                     = replace("${var.prefix}stor${var.environment}", "-", "")
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = var.tags
}

resource "azurerm_storage_container" "invoices" {
  name                   = "invoices"
  storage_account_name   = azurerm_storage_account.main.name
  container_access_type  = "private"
}

output "connection_string" {
  value     = azurerm_storage_account.main.primary_connection_string
  sensitive = true
}

output "account_name" {
  value = azurerm_storage_account.main.name
}

output "primary_access_key" {
  value     = azurerm_storage_account.main.primary_access_key
  sensitive = true
}
