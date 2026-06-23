data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "main" {
  name                = "${var.prefix}-kv-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  # Enable RBAC instead of legacy access policies (best practice)
  enable_rbac_authorization = true

  tags = var.tags
}

# Grant the App Service managed identity GET/LIST on secrets
resource "azurerm_role_assignment" "app_service_kv" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.app_service_principal_id
}

# Store secrets
resource "azurerm_key_vault_secret" "cosmos" {
  name         = "CosmosConnectionString"
  value        = var.cosmos_connection_string
  key_vault_id = azurerm_key_vault.main.id

  depends_on = [azurerm_role_assignment.app_service_kv]
}

resource "azurerm_key_vault_secret" "sql" {
  name         = "SqlConnectionString"
  value        = var.sql_connection_string
  key_vault_id = azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "servicebus" {
  name         = "ServiceBusConnectionString"
  value        = var.servicebus_connection_string
  key_vault_id = azurerm_key_vault.main.id
}
