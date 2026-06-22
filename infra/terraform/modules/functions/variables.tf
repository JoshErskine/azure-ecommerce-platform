variable "prefix" { type = string }
variable "environment" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "tags" { type = map(string) }
variable "storage_account_name" { type = string }
variable "storage_account_key" {
  type      = string
  sensitive = true
}
variable "storage_connection_string" {
  type      = string
  sensitive = true
}
variable "servicebus_connection_string" {
  type      = string
  sensitive = true
}
variable "blob_connection_string" {
  type      = string
  sensitive = true
}
variable "service_plan_id" { type = string }
