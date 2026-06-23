variable "prefix" { type = string }
variable "environment" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "tags" { type = map(string) }
variable "app_service_principal_id" { type = string }
variable "cosmos_connection_string" {
  type      = string
  sensitive = true
}
variable "sql_connection_string" {
  type      = string
  sensitive = true
}
variable "servicebus_connection_string" {
  type      = string
  sensitive = true
}
