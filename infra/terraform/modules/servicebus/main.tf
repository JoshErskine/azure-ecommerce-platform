resource "azurerm_servicebus_namespace" "main" {
  name                = "${var.prefix}-sb-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_servicebus_queue" "orders" {
  name         = "orders-queue"
  namespace_id = azurerm_servicebus_namespace.main.id

  # Dead-letter queue enabled — failed messages are preserved
  dead_lettering_on_message_expiration = true
  max_delivery_count                   = 3
  default_message_ttl                  = "P7D"
}

output "connection_string" {
  value     = azurerm_servicebus_namespace.main.default_primary_connection_string
  sensitive = true
}
