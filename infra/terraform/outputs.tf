output "app_service_url" {
  value       = "https://${module.appservice.default_hostname}"
  description = "Live API URL — append /scalar/v1 for Scalar UI"
}

output "apim_gateway_url" {
  value       = "https://${module.apim.gateway_hostname}/ecommerce"
  description = "API Management gateway URL"
}

output "resource_group_name" {
  value = azurerm_resource_group.main.name
}
