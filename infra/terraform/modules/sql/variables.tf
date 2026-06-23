variable "prefix" { type = string }
variable "environment" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "tags" { type = map(string) }
variable "sql_admin_password" {
  type      = string
  sensitive = true
}
